--[[
JericoFX
ox_lib db builder (oxmysql)
Simple query builder + transaction helper.

Main idea (easy rule):
- Use :run() for the "normal result"
- Use :one() when you want only 1 row
- Use :value('col') when you want only 1 value
- Use :exists() / :count() for booleans and numbers

Why:
- oxmysql has different calls: query/single/scalar/insert/update
- so we use clear "finishers" to avoid confusion.

----------------------------------------------------------------------
BASIC EXAMPLES
----------------------------------------------------------------------

1) SELECT many rows (list):
local rows = lib.db('users')
    :select('id', 'name', 'job')
    :where('job', 'police')
    :orderBy('id', 'DESC')
    :limit(50)
    :run()

2) SELECT one row (single row):
local user = lib.db('users')
    :select('*')
    :where('id', 1)
    :one()

3) SELECT one value (scalar):
local money = lib.db('users')
    :where('id', 1)
    :value('money')

4) INSERT (returns insertId):
local id = lib.db('users')
    :insert({ name = 'Joan', job = 'ems', money = 100 })
    :run()

5) UPDATE (returns affected rows):
local affected = lib.db('users')
    :update({ money = 200 })
    :where('id', 1)
    :run()

6) DELETE (returns affected rows):
local affected = lib.db('users')
    :delete()
    :where('id', 1)
    :run()

7) UPSERT (INSERT ... ON DUPLICATE KEY UPDATE):
-- insertData = new row
-- updateData = what to update if duplicate (optional)
local res = lib.db('management_funds')
    :upsert(
        { job_name = job, amount = amount, type = 'boss' },
        { amount = amount }
    )
    :run()

----------------------------------------------------------------------
HELPERS (fast and clear)
----------------------------------------------------------------------

A) exists() -> boolean
local ok = lib.db('users')
    :where('license', license)
    :exists()

B) count() -> number
local total = lib.db('users')
    :where('job', 'police')
    :count()

----------------------------------------------------------------------
TRANSACTION (atomic writes)
----------------------------------------------------------------------

You can do:
lib.db.transaction(function(tx)
    tx:update('UPDATE users SET money = money - ? WHERE id = ?', { 50, 1 })
    tx:update('UPDATE users SET money = money + ? WHERE id = ?', { 50, 2 })
end)

Notes (pls read):
- Inside tx, this is a "batch tranzaction".
- You CAN queue writes.
- You CAN NOT do :get() / :one() / :value() inside tx (no intermediat resutls).
- If you use tx:db(...), you MUST finish with :run() or it will error.

Example with tx:db (builder inside tx):
lib.db.transaction(function(tx)
    tx:db('users'):update({ money = 100 }):where('id', 1):run()
    tx:db('users'):update({ money = 200 }):where('id', 2):run()
end)

If you forgget :run() -> it will throw error like:
"A query builder was used inside tx:db(...) but never executed. Did you forget :run()?"

----------------------------------------------------------------------
COMMON "WHAT DO I USE?" (quick guide)
----------------------------------------------------------------------

- I want rows -> :run()
- I want 1 row -> :one()
- I want 1 value -> :value('col')
- I want true/false -> :exists()
- I want a number -> :count()
]]

if type(MySQL) ~= 'table' then
    error('[ox_lib][db] MySQL (oxmysql) not found. Ensure oxmysql is started before ox_lib.', 2)
end

local _MySQL = MySQL
local concat = table.concat
local sort = table.sort
local upper = string.upper
local tonumber = tonumber
local tostring = tostring
local type = type
local pairs = pairs
local ipairs = ipairs
local setmetatable = setmetatable
local error = error

local function isArray(t)
    if type(t) ~= 'table' then return false end
    local n = #t
    if n == 0 then return false end
    for i = 1, n do
        if rawget(t, i) == nil then return false end
    end
    return true
end

local function assertIdent(s, kind)
    if type(s) ~= 'string' or not s:match('^[%a_][%w_]*$') then
        error(('[ox_lib][db] invalid %s identifier: %s'):format(kind or 'identifier', tostring(s)), 3)
    end
    return s
end

local function escIdent(s)
    assertIdent(s, 'identifier')
    return ('`%s`'):format(s)
end

local function escIdentDot(s)
    if type(s) ~= 'string' then
        error(('[ox_lib][db] invalid identifier: %s'):format(tostring(s)), 3)
    end
    if s == '*' then return '*' end
    if s:find('%.', 1, true) then
        local a, b = s:match('^([%a_][%w_]*)%.([%a_][%w_]*|%*)$')
        if not a or not b then
            error(('[ox_lib][db] invalid dotted identifier: %s'):format(tostring(s)), 3)
        end
        if b == '*' then
            return ('%s.*'):format(escIdent(a))
        end
        return ('%s.%s'):format(escIdent(a), escIdent(b))
    end
    return escIdent(s)
end

local ALLOWED_OP = {
    ['='] = true, ['!='] = true, ['<>'] = true,
    ['<'] = true, ['<='] = true, ['>'] = true, ['>='] = true,
    ['LIKE'] = true, ['NOT LIKE'] = true,
    ['IN'] = true, ['NOT IN'] = true,
    ['IS'] = true, ['IS NOT'] = true,
    ['BETWEEN'] = true, ['NOT BETWEEN'] = true,
}

local function normOp(op)
    op = upper(tostring(op))
    if not ALLOWED_OP[op] then
        error(('[ox_lib][db] invalid operator: %s'):format(tostring(op)), 3)
    end
    return op
end

local function normDir(dir)
    dir = upper(tostring(dir or 'ASC'))
    if dir ~= 'ASC' and dir ~= 'DESC' then
        error(('[ox_lib][db] invalid order direction: %s'):format(tostring(dir)), 3)
    end
    return dir
end

local function keysSorted(t)
    local keys = {}
    local n = 0
    for k in pairs(t) do
        assertIdent(k, 'column')
        n = n + 1
        keys[n] = k
    end
    sort(keys)
    return keys
end

local function pushParams(dst, values)
    for i = 1, #values do
        dst[#dst + 1] = values[i]
    end
end

local QueryBuilder = {}
QueryBuilder.__index = QueryBuilder

local function newBuilder(table_name)
    assertIdent(table_name, 'table')
    local self = setmetatable({}, QueryBuilder)
    self.table = table_name

    self._type = 'SELECT'
    self._distinct = false

    self._selects = { '*' }
    self._joins = nil

    self._wheres = nil
    self._groupBy = nil
    self._having = nil

    self._orders = nil
    self._limit = nil
    self._offset = nil

    self._insert = nil
    self._update = nil
    self._upsert = nil
    self._insertMany = nil

    self._lock = nil
    return self
end

function QueryBuilder:distinct(enable)
    self._distinct = (enable == nil) and true or not not enable
    return self
end

function QueryBuilder:select(...)
    self._type = 'SELECT'
    local cols = { ... }
    if #cols == 1 and type(cols[1]) == 'table' then cols = cols[1] end
    if #cols == 0 then
        self._selects = { '*' }
        return self
    end
    local out = {}
    for i = 1, #cols do
        out[i] = escIdentDot(cols[i])
    end
    self._selects = out
    return self
end

function QueryBuilder:from(table_name, alias)
    assertIdent(table_name, 'table')
    self.table = table_name
    if alias ~= nil then
        assertIdent(alias, 'alias')
        self._fromAlias = alias
    end
    return self
end

local function addJoin(self, joinType, table_name, left, op, right)
    assertIdent(table_name, 'table')
    if type(left) ~= 'string' or type(right) ~= 'string' then
        error('[ox_lib][db] join expects string identifiers for left/right', 3)
    end
    op = normOp(op)
    if joinType ~= 'JOIN' and joinType ~= 'LEFT JOIN' then
        error('[ox_lib][db] invalid join type', 3)
    end
    self._joins = self._joins or {}
    self._joins[#self._joins + 1] = {
        t = joinType,
        table = table_name,
        left = left,
        op = op,
        right = right,
    }
    return self
end

function QueryBuilder:join(table_name, left, op, right)
    return addJoin(self, 'JOIN', table_name, left, op, right)
end

function QueryBuilder:leftJoin(table_name, left, op, right)
    return addJoin(self, 'LEFT JOIN', table_name, left, op, right)
end

local function ensureWheres(self)
    if not self._wheres then self._wheres = {} end
    return self._wheres
end

local function whereBasic(self, bool, column, operator, value)
    assertIdentDot(column)
    if value == nil then
        value = operator
        operator = '='
    end
    operator = normOp(operator)
    local wheres = ensureWheres(self)
    wheres[#wheres + 1] = { k = 'basic', b = bool, c = column, o = operator, v = value }
    return self
end

function QueryBuilder:where(column, operator, value)
    return whereBasic(self, 'AND', column, operator, value)
end

function QueryBuilder:orWhere(column, operator, value)
    return whereBasic(self, 'OR', column, operator, value)
end

local function whereNull(self, bool, column, notNull)
    assertIdentDot(column)
    local wheres = ensureWheres(self)
    wheres[#wheres + 1] = { k = 'null', b = bool, c = column, n = not notNull }
    return self
end

function QueryBuilder:whereNull(column)
    return whereNull(self, 'AND', column, false)
end

function QueryBuilder:whereNotNull(column)
    return whereNull(self, 'AND', column, true)
end

function QueryBuilder:orWhereNull(column)
    return whereNull(self, 'OR', column, false)
end

function QueryBuilder:orWhereNotNull(column)
    return whereNull(self, 'OR', column, true)
end

local function whereIn(self, bool, column, values, notIn)
    assertIdentDot(column)
    if type(values) ~= 'table' or #values == 0 then
        error('[ox_lib][db] whereIn expects a non-empty array', 3)
    end
    local wheres = ensureWheres(self)
    wheres[#wheres + 1] = { k = 'in', b = bool, c = column, vals = values, n = not notIn }
    return self
end

function QueryBuilder:whereIn(column, values)
    return whereIn(self, 'AND', column, values, false)
end

function QueryBuilder:whereNotIn(column, values)
    return whereIn(self, 'AND', column, values, true)
end

function QueryBuilder:orWhereIn(column, values)
    return whereIn(self, 'OR', column, values, false)
end

function QueryBuilder:orWhereNotIn(column, values)
    return whereIn(self, 'OR', column, values, true)
end

local function whereBetween(self, bool, column, a, b, notBetween)
    assertIdentDot(column)
    if a == nil or b == nil then
        error('[ox_lib][db] whereBetween expects (column, a, b)', 3)
    end
    local wheres = ensureWheres(self)
    wheres[#wheres + 1] = { k = 'between', b = bool, c = column, a = a, d = b, n = not notBetween }
    return self
end

function QueryBuilder:whereBetween(column, a, b)
    return whereBetween(self, 'AND', column, a, b, false)
end

function QueryBuilder:whereNotBetween(column, a, b)
    return whereBetween(self, 'AND', column, a, b, true)
end

function QueryBuilder:orWhereBetween(column, a, b)
    return whereBetween(self, 'OR', column, a, b, false)
end

function QueryBuilder:orWhereNotBetween(column, a, b)
    return whereBetween(self, 'OR', column, a, b, true)
end

local function whereGroup(self, bool, fn)
    if type(fn) ~= 'function' then
        error('[ox_lib][db] whereGroup expects a function', 3)
    end
    local sub = newBuilder(self.table)
    sub._type = 'SELECT'
    fn(sub)

    if not sub._wheres or #sub._wheres == 0 then
        return self
    end

    local wheres = ensureWheres(self)
    wheres[#wheres + 1] = { k = 'group', b = bool, w = sub._wheres }
    return self
end

function QueryBuilder:whereGroup(fn)
    return whereGroup(self, 'AND', fn)
end

function QueryBuilder:orWhereGroup(fn)
    return whereGroup(self, 'OR', fn)
end

local function ensureHaving(self)
    if not self._having then self._having = {} end
    return self._having
end

local function havingBasic(self, bool, column, operator, value)
    assertIdentDot(column)
    if value == nil then
        value = operator
        operator = '='
    end
    operator = normOp(operator)
    local having = ensureHaving(self)
    having[#having + 1] = { b = bool, c = column, o = operator, v = value }
    return self
end

function QueryBuilder:having(column, operator, value)
    return havingBasic(self, 'AND', column, operator, value)
end

function QueryBuilder:orHaving(column, operator, value)
    return havingBasic(self, 'OR', column, operator, value)
end

function QueryBuilder:groupBy(...)
    local cols = { ... }
    if #cols == 1 and type(cols[1]) == 'table' then cols = cols[1] end
    if #cols == 0 then return self end
    local out = {}
    for i = 1, #cols do
        out[i] = escIdentDot(cols[i])
    end
    self._groupBy = out
    return self
end

function QueryBuilder:orderBy(column, direction)
    assertIdentDot(column)
    self._orders = self._orders or {}
    self._orders[#self._orders + 1] = { c = column, d = normDir(direction) }
    return self
end

function QueryBuilder:limit(n)
    n = tonumber(n)
    if not n or n < 0 then error('[ox_lib][db] invalid limit', 3) end
    self._limit = n
    return self
end

function QueryBuilder:offset(n)
    n = tonumber(n)
    if not n or n < 0 then error('[ox_lib][db] invalid offset', 3) end
    self._offset = n
    return self
end

function QueryBuilder:page(page, perPage)
    page = tonumber(page)
    perPage = tonumber(perPage)
    if not page or page < 1 then error('[ox_lib][db] invalid page', 3) end
    if not perPage or perPage < 1 then error('[ox_lib][db] invalid perPage', 3) end
    self._limit = perPage
    self._offset = (page - 1) * perPage
    return self
end

function QueryBuilder:lock(mode)
    if mode == nil then
        self._lock = 'FOR UPDATE'
        return self
    end
    mode = upper(tostring(mode))
    if mode ~= 'FOR UPDATE' and mode ~= 'LOCK IN SHARE MODE' then
        error('[ox_lib][db] invalid lock mode', 3)
    end
    self._lock = mode
    return self
end

function QueryBuilder:insert(data)
    if type(data) ~= 'table' then error('[ox_lib][db] insert expects table', 3) end
    self._type = 'INSERT'
    self._insert = data
    return self
end

function QueryBuilder:insertMany(rows)
    if type(rows) ~= 'table' or #rows == 0 then
        error('[ox_lib][db] insertMany expects a non-empty array of rows', 3)
    end
    for i = 1, #rows do
        if type(rows[i]) ~= 'table' then
            error('[ox_lib][db] insertMany expects each row to be a table', 3)
        end
    end
    self._type = 'INSERT_MANY'
    self._insertMany = rows
    return self
end

function QueryBuilder:update(data)
    if type(data) ~= 'table' then error('[ox_lib][db] update expects table', 3) end
    self._type = 'UPDATE'
    self._update = data
    return self
end

function QueryBuilder:delete()
    self._type = 'DELETE'
    return self
end

function QueryBuilder:upsert(insertData, updateData)
    if type(insertData) ~= 'table' then error('[ox_lib][db] upsert insertData must be table', 3) end
    if updateData ~= nil and type(updateData) ~= 'table' then error('[ox_lib][db] upsert updateData must be table', 3) end
    self._type = 'UPSERT'
    self._upsert = { insert = insertData, update = updateData }
    return self
end

local function buildWhereList(list, params, out, isFirst)
    local first = isFirst
    for i = 1, #list do
        local w = list[i]
        local bool = w.b
        local prefix = ''
        if first then
            prefix = ''
            first = false
        else
            prefix = ' ' .. bool .. ' '
        end

        if w.k == 'basic' then
            out[#out + 1] = prefix .. ('%s %s ?'):format(escIdentDot(w.c), w.o)
            params[#params + 1] = w.v

        elseif w.k == 'null' then
            out[#out + 1] = prefix .. ('%s IS %sNULL'):format(escIdentDot(w.c), w.n and 'NOT ' or '')

        elseif w.k == 'in' then
            local vals = w.vals
            local ph = {}
            for j = 1, #vals do
                ph[j] = '?'
                params[#params + 1] = vals[j]
            end
            out[#out + 1] = prefix .. ('%s %s (%s)'):format(escIdentDot(w.c), w.n and 'NOT IN' or 'IN', concat(ph, ', '))

        elseif w.k == 'between' then
            out[#out + 1] = prefix .. ('%s %s ? AND ?'):format(escIdentDot(w.c), w.n and 'NOT BETWEEN' or 'BETWEEN')
            params[#params + 1] = w.a
            params[#params + 1] = w.d

        elseif w.k == 'group' then
            local subOut = {}
            buildWhereList(w.w, params, subOut, true)
            out[#out + 1] = prefix .. '(' .. concat(subOut, '') .. ')'
        end
    end
end

local function buildHavingList(list, params, out)
    local first = true
    for i = 1, #list do
        local h = list[i]
        local prefix
        if first then
            prefix = ''
            first = false
        else
            prefix = ' ' .. h.b .. ' '
        end
        out[#out + 1] = prefix .. ('%s %s ?'):format(escIdentDot(h.c), h.o)
        params[#params + 1] = h.v
    end
end

local function buildSelect(self, params)
    local parts = {}

    local distinct = self._distinct and 'DISTINCT ' or ''
    local from = escIdent(self.table)
    if self._fromAlias then
        from = from .. ' AS ' .. escIdent(self._fromAlias)
    end

    parts[#parts + 1] = ('SELECT %s%s FROM %s'):format(distinct, concat(self._selects, ', '), from)

    if self._joins and #self._joins > 0 then
        for i = 1, #self._joins do
            local j = self._joins[i]
            parts[#parts + 1] = (' %s %s ON %s %s %s'):format(
                j.t,
                escIdent(j.table),
                escIdentDot(j.left),
                j.op,
                escIdentDot(j.right)
            )
        end
    end

    if self._wheres and #self._wheres > 0 then
        local wOut = {}
        buildWhereList(self._wheres, params, wOut, true)
        parts[#parts + 1] = ' WHERE ' .. concat(wOut, '')
    end

    if self._groupBy and #self._groupBy > 0 then
        parts[#parts + 1] = ' GROUP BY ' .. concat(self._groupBy, ', ')
    end

    if self._having and #self._having > 0 then
        local hOut = {}
        buildHavingList(self._having, params, hOut)
        parts[#parts + 1] = ' HAVING ' .. concat(hOut, '')
    end

    if self._orders and #self._orders > 0 then
        local o = {}
        for i = 1, #self._orders do
            local v = self._orders[i]
            o[i] = ('%s %s'):format(escIdentDot(v.c), v.d)
        end
        parts[#parts + 1] = ' ORDER BY ' .. concat(o, ', ')
    end

    if self._limit ~= nil then
        parts[#parts + 1] = ' LIMIT ?'
        params[#params + 1] = self._limit
        if self._offset ~= nil then
            parts[#parts + 1] = ' OFFSET ?'
            params[#params + 1] = self._offset
        end
    end

    if self._lock then
        parts[#parts + 1] = ' ' .. self._lock
    end

    return concat(parts, '')
end

local function buildInsert(self, params)
    local data = self._insert
    local keys = keysSorted(data)

    local cols = {}
    local ph = {}
    for i = 1, #keys do
        local k = keys[i]
        cols[i] = escIdent(k)
        ph[i] = '?'
        params[i] = data[k]
    end

    return ('INSERT INTO %s (%s) VALUES (%s)'):format(
        escIdent(self.table),
        concat(cols, ', '),
        concat(ph, ', ')
    )
end

local function buildInsertMany(self, params)
    local rows = self._insertMany
    local first = rows[1]
    local keys = keysSorted(first)

    local cols = {}
    for i = 1, #keys do
        cols[i] = escIdent(keys[i])
    end

    local valuesParts = {}
    local p = 0

    for r = 1, #rows do
        local row = rows[r]
        local tuple = {}
        for i = 1, #keys do
            local k = keys[i]
            tuple[i] = '?'
            p = p + 1
            params[p] = row[k]
        end
        valuesParts[r] = '(' .. concat(tuple, ', ') .. ')'
    end

    return ('INSERT INTO %s (%s) VALUES %s'):format(
        escIdent(self.table),
        concat(cols, ', '),
        concat(valuesParts, ', ')
    )
end

local function buildUpdate(self, params)
    local data = self._update
    local keys = keysSorted(data)

    local sets = {}
    for i = 1, #keys do
        local k = keys[i]
        sets[i] = ('%s = ?'):format(escIdent(k))
        params[i] = data[k]
    end

    local parts = {}
    parts[#parts + 1] = ('UPDATE %s SET %s'):format(escIdent(self.table), concat(sets, ', '))

    if self._wheres and #self._wheres > 0 then
        local wOut = {}
        buildWhereList(self._wheres, params, wOut, true)
        parts[#parts + 1] = ' WHERE ' .. concat(wOut, '')
    end

    if self._orders and #self._orders > 0 then
        local o = {}
        for i = 1, #self._orders do
            local v = self._orders[i]
            o[i] = ('%s %s'):format(escIdentDot(v.c), v.d)
        end
        parts[#parts + 1] = ' ORDER BY ' .. concat(o, ', ')
    end

    if self._limit ~= nil then
        parts[#parts + 1] = ' LIMIT ?'
        params[#params + 1] = self._limit
    end

    return concat(parts, '')
end

local function buildDelete(self, params)
    local parts = {}
    parts[#parts + 1] = ('DELETE FROM %s'):format(escIdent(self.table))

    if self._wheres and #self._wheres > 0 then
        local wOut = {}
        buildWhereList(self._wheres, params, wOut, true)
        parts[#parts + 1] = ' WHERE ' .. concat(wOut, '')
    end

    if self._orders and #self._orders > 0 then
        local o = {}
        for i = 1, #self._orders do
            local v = self._orders[i]
            o[i] = ('%s %s'):format(escIdentDot(v.c), v.d)
        end
        parts[#parts + 1] = ' ORDER BY ' .. concat(o, ', ')
    end

    if self._limit ~= nil then
        parts[#parts + 1] = ' LIMIT ?'
        params[#params + 1] = self._limit
    end

    return concat(parts, '')
end

local function buildUpsert(self, params)
    local u = self._upsert
    local insertData = u.insert
    local updateData = u.update

    local insertKeys = keysSorted(insertData)
    local cols = {}
    local ph = {}
    local p = 0

    for i = 1, #insertKeys do
        local k = insertKeys[i]
        cols[i] = escIdent(k)
        ph[i] = '?'
        p = p + 1
        params[p] = insertData[k]
    end

    local updateKeys
    if updateData then
        updateKeys = keysSorted(updateData)
    else
        updateKeys = insertKeys
    end

    local sets = {}
    for i = 1, #updateKeys do
        local k = updateKeys[i]
        assertIdent(k, 'column')
        sets[i] = ('%s = ?'):format(escIdent(k))
        p = p + 1
        params[p] = updateData and updateData[k] or insertData[k]
    end

    return ('INSERT INTO %s (%s) VALUES (%s) ON DUPLICATE KEY UPDATE %s'):format(
        escIdent(self.table),
        concat(cols, ', '),
        concat(ph, ', '),
        concat(sets, ', ')
    )
end

function QueryBuilder:toSQL()
    local params = {}
    local sql
    if self._type == 'SELECT' then
        sql = buildSelect(self, params)
    elseif self._type == 'INSERT' then
        sql = buildInsert(self, params)
    elseif self._type == 'INSERT_MANY' then
        sql = buildInsertMany(self, params)
    elseif self._type == 'UPDATE' then
        sql = buildUpdate(self, params)
    elseif self._type == 'DELETE' then
        sql = buildDelete(self, params)
    elseif self._type == 'UPSERT' then
        sql = buildUpsert(self, params)
    else
        error('[ox_lib][db] unknown query type', 3)
    end
    return sql, params
end

function QueryBuilder:execute()
    local sql, params = self:toSQL()

    if self._type == 'SELECT' then
        return _MySQL.query.await(sql, params)
    elseif self._type == 'INSERT' then
        return _MySQL.insert.await(sql, params)
    elseif self._type == 'INSERT_MANY' then
        return _MySQL.insert.await(sql, params)
    elseif self._type == 'UPDATE' then
        return _MySQL.update.await(sql, params)
    elseif self._type == 'DELETE' then
        return _MySQL.update.await(sql, params)
    elseif self._type == 'UPSERT' then
        return _MySQL.insert.await(sql, params)
    end
end

function QueryBuilder:get()
    self._type = 'SELECT'
    return self:execute()
end

function QueryBuilder:first()
    self._type = 'SELECT'
    self:limit(1)
    local row = _MySQL.single.await((self:toSQL()))
    return row
end

function QueryBuilder:single()
    self._type = 'SELECT'
    return _MySQL.single.await((self:toSQL()))
end

function QueryBuilder:scalar()
    self._type = 'SELECT'
    return _MySQL.scalar.await((self:toSQL()))
end

function QueryBuilder:count(column)
    self._type = 'SELECT'
    local col = column and escIdentDot(column) or '*'
    self._selects = { ('COUNT(%s) as `count`'):format(col) }
    self._orders = nil
    self._limit = nil
    self._offset = nil
    local v = _MySQL.scalar.await((self:toSQL()))
    return tonumber(v) or 0
end

function QueryBuilder:exists()
    self._type = 'SELECT'
    self._selects = { '1' }
    self._orders = nil
    self:limit(1)
    local row = _MySQL.single.await((self:toSQL()))
    return row ~= nil
end

function QueryBuilder:pluck(column)
    self._type = 'SELECT'
    assertIdentDot(column)
    self._selects = { escIdentDot(column) }
    local rows = _MySQL.query.await((self:toSQL()))
    local out = {}
    if rows then
        for i = 1, #rows do
            local r = rows[i]
            out[#out + 1] = r[column] or r[column:gsub('^.*%.', '')]
        end
    end
    return out
end

function QueryBuilder:value(column)
    self._type = 'SELECT'
    assertIdentDot(column)
    self._selects = { escIdentDot(column) }
    self._orders = nil
    self:limit(1)
    return _MySQL.scalar.await((self:toSQL()))
end

function QueryBuilder:run()
    return self:execute()
end

local db = {}

function db.raw(sql, params)
    if type(sql) ~= 'string' then error('[ox_lib][db] raw expects sql string', 2) end
    return _MySQL.query.await(sql, params or {})
end

function db.prepare(sql, params)
    if type(sql) ~= 'string' then error('[ox_lib][db] prepare expects sql string', 2) end
    return _MySQL.prepare.await(sql, params or {})
end

local function makeTx()
    local tx = {}
    tx._queries = {}
    tx._builders = {}

    local function push(query, values)
        if type(query) ~= 'string' then
            error('[ox_lib][db] tx expects query as string', 3)
        end
        tx._queries[#tx._queries + 1] = {
            query = query,
            values = values or {}
        }
        return tx
    end

    function tx:raw(query, values)    return push(query, values) end
    function tx:query(query, values)  return push(query, values) end
    function tx:update(query, values) return push(query, values) end
    function tx:insert(query, values) return push(query, values) end
    function tx:prepare(query, values)return push(query, values) end

    -- Optional: tx:db('table') builder enqueues on :run()
    function tx:db(table_name)
        local qb = newBuilder(table_name)
        qb.__tx_dirty = false
        qb.__tx_executed = false

        tx._builders[#tx._builders + 1] = qb

        local function markDirty()
            qb.__tx_dirty = true
        end

        -- wrap mutating/chaining methods to mark dirty
        local chainFns = {
            'distinct','select','from','join','leftJoin',
            'where','orWhere','whereNull','whereNotNull','orWhereNull','orWhereNotNull',
            'whereIn','whereNotIn','orWhereIn','orWhereNotIn',
            'whereBetween','whereNotBetween','orWhereBetween','orWhereNotBetween',
            'whereGroup','orWhereGroup',
            'groupBy','having','orHaving',
            'orderBy','limit','offset','page','lock',
            'insert','insertMany','update','delete','upsert',
        }

        for i = 1, #chainFns do
            local name = chainFns[i]
            local orig = qb[name]
            if type(orig) == 'function' then
                qb[name] = function(self, ...)
                    markDirty()
                    return orig(self, ...)
                end
            end
        end

        function qb:run()
            markDirty()
            local sql, params = self:toSQL()
            push(sql, params)
            self.__tx_executed = true
            return true
        end

        qb.execute = qb.run

        local function notSupported(method)
            return function()
                error(('[ox_lib][db] tx:db(...):%s() is not supported inside transaction batch. Use :run() to enqueue writes, or do reads outside the tx.'):format(method), 2)
            end
        end

        qb.get = notSupported('get')
        qb.first = notSupported('first')
        qb.single = notSupported('single')
        qb.scalar = notSupported('scalar')
        qb.value = notSupported('value')
        qb.exists = notSupported('exists')
        qb.count = notSupported('count')
        qb.pluck = notSupported('pluck')

        return qb
    end

    function tx:_assertNoForgottenBuilders()
        for i = 1, #self._builders do
            local qb = self._builders[i]
            if qb.__tx_dirty and not qb.__tx_executed then
                error('[ox_lib][db] A query builder was used inside tx:db(...) but never executed. Did you forget :run()?', 3)
            end
        end
    end

    return tx
end

function db.transaction(arg)
    if type(arg) == 'table' then
        if #arg == 0 then error('[ox_lib][db] transaction expects non-empty array', 2) end
        return _MySQL.transaction.await(arg)
    end

    -- New style: function(tx)
    if type(arg) ~= 'function' then
        error('[ox_lib][db] transaction expects a function(tx) or an array of queries', 2)
    end

    local tx = makeTx()
    arg(tx)

    -- guard: forgot :run()
    if tx._builders and #tx._builders > 0 then
        tx:_assertNoForgottenBuilders()
    end

    if #tx._queries == 0 then
        return true
    end

    return _MySQL.transaction.await(tx._queries)
end

function db.scalar(sql, params)
    if type(sql) ~= 'string' then error('[ox_lib][db] scalar expects sql string', 2) end
    return _MySQL.scalar.await(sql, params or {})
end

function db.single(sql, params)
    if type(sql) ~= 'string' then error('[ox_lib][db] single expects sql string', 2) end
    return _MySQL.single.await(sql, params or {})
end

function db.query(sql, params)
    if type(sql) ~= 'string' then error('[ox_lib][db] query expects sql string', 2) end
    return _MySQL.query.await(sql, params or {})
end

function db.insert(sql, params)
    if type(sql) ~= 'string' then error('[ox_lib][db] insert expects sql string', 2) end
    return _MySQL.insert.await(sql, params or {})
end

function db.update(sql, params)
    if type(sql) ~= 'string' then error('[ox_lib][db] update expects sql string', 2) end
    return _MySQL.update.await(sql, params or {})
end

function db.escapeIdent(name)
    return escIdent(name)
end

function db.escapeIdentDot(name)
    return escIdentDot(name)
end

setmetatable(db, {
    __call = function(_, table_name)
        return newBuilder(table_name)
    end
})

lib.db = db
