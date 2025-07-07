---@meta

---@class lib.phone
---@field sendMessage fun(number: string, message: string): boolean
---@field addContact fun(name: string, number: string, avatar?: string): boolean
---@field removeContact fun(number: string): boolean
---@field notification fun(title: string, text: string, icon?: string, color?: string, timeout?: number): boolean
---@field open fun(): boolean
---@field close fun(): boolean
---@field isOpen fun(): boolean
---@field makeCall fun(number: string): boolean
---@field answerCall fun(): boolean
---@field declineCall fun(): boolean
---@field endCall fun(): boolean
---@field isInCall fun(): boolean
---@field takePhoto fun(): boolean
---@field openGallery fun(): boolean
---@field openApp fun(appName: string): boolean
---@field closeApp fun(appName: string): boolean
---@field getPhoneNumber fun(): string?
---@field getContacts fun(): table?
---@field updateContact fun(id: any, data: table): boolean
---@field deletePhoto fun(photoId: any): boolean
---@field sharePhoto fun(photoId: any, contacts: table): boolean
---@field installApp fun(appId: string): boolean
---@field uninstallApp fun(appId: string): boolean
---@field getInstalledApps fun(): table

---@class lib.shops
---@field createShop fun(shopData: table): boolean
---@field openShop fun(shopName: string, playerSource?: number): boolean
---@field addShopItem fun(shopName: string, itemData: table): boolean
---@field removeShopItem fun(shopName: string, itemName: string, amount?: number): boolean
---@field updateShopItem fun(shopName: string, itemName: string, updateData: table): boolean
---@field getShop fun(shopName: string): table?
---@field deleteShop fun(shopName: string): boolean
---@field getAllShops fun(): table
---@field buyItem fun(shopName: string, itemName: string, amount?: number): boolean
---@field shopExists fun(shopName: string): boolean
---@field createQuickShop fun(name: string, label: string, coords: vector3, items?: table): boolean
---@field getShopItems fun(shopName: string): table
---@field clearShop fun(shopName: string): boolean
---@field populateShop fun(shopName: string, items: table): boolean

-- Initialize normalizer tables if they don't exist
lib.phone = lib.phone or {}
lib.shops = lib.shops or {}

-- Export phone functions
exports('phone_sendMessage', function(...) return lib.phone.sendMessage(...) end)
exports('phone_addContact', function(...) return lib.phone.addContact(...) end)
exports('phone_removeContact', function(...) return lib.phone.removeContact(...) end)
exports('phone_notification', function(...) return lib.phone.notification(...) end)
exports('phone_open', function(...) return lib.phone.open(...) end)
exports('phone_close', function(...) return lib.phone.close(...) end)
exports('phone_isOpen', function(...) return lib.phone.isOpen(...) end)
exports('phone_makeCall', function(...) return lib.phone.makeCall(...) end)
exports('phone_answerCall', function(...) return lib.phone.answerCall(...) end)
exports('phone_declineCall', function(...) return lib.phone.declineCall(...) end)
exports('phone_endCall', function(...) return lib.phone.endCall(...) end)
exports('phone_isInCall', function(...) return lib.phone.isInCall(...) end)
exports('phone_takePhoto', function(...) return lib.phone.takePhoto(...) end)
exports('phone_openGallery', function(...) return lib.phone.openGallery(...) end)
exports('phone_openApp', function(...) return lib.phone.openApp(...) end)
exports('phone_closeApp', function(...) return lib.phone.closeApp(...) end)
exports('phone_getPhoneNumber', function(...) return lib.phone.getPhoneNumber(...) end)
exports('phone_getContacts', function(...) return lib.phone.getContacts(...) end)
exports('phone_updateContact', function(...) return lib.phone.updateContact(...) end)
exports('phone_deletePhoto', function(...) return lib.phone.deletePhoto(...) end)
exports('phone_sharePhoto', function(...) return lib.phone.sharePhoto(...) end)
exports('phone_installApp', function(...) return lib.phone.installApp(...) end)
exports('phone_uninstallApp', function(...) return lib.phone.uninstallApp(...) end)
exports('phone_getInstalledApps', function(...) return lib.phone.getInstalledApps(...) end)

-- Export shop functions
exports('shops_createShop', function(...) return lib.shops.createShop(...) end)
exports('shops_openShop', function(...) return lib.shops.openShop(...) end)
exports('shops_addShopItem', function(...) return lib.shops.addShopItem(...) end)
exports('shops_removeShopItem', function(...) return lib.shops.removeShopItem(...) end)
exports('shops_updateShopItem', function(...) return lib.shops.updateShopItem(...) end)
exports('shops_getShop', function(...) return lib.shops.getShop(...) end)
exports('shops_deleteShop', function(...) return lib.shops.deleteShop(...) end)
exports('shops_getAllShops', function(...) return lib.shops.getAllShops(...) end)
exports('shops_buyItem', function(...) return lib.shops.buyItem(...) end)
exports('shops_shopExists', function(...) return lib.shops.shopExists(...) end)
exports('shops_createQuickShop', function(...) return lib.shops.createQuickShop(...) end)
exports('shops_getShopItems', function(...) return lib.shops.getShopItems(...) end)
exports('shops_clearShop', function(...) return lib.shops.clearShop(...) end)
exports('shops_populateShop', function(...) return lib.shops.populateShop(...) end) 