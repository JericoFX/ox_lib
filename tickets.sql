CREATE TABLE IF NOT EXISTS `player_tickets` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `reporter_id` int(11) NOT NULL,
    `reporter_license` varchar(100) NOT NULL,
    `reporter_name` varchar(100) NOT NULL,
    `target_id` int(11) DEFAULT NULL,
    `target_license` varchar(100) DEFAULT NULL,
    `target_name` varchar(100) DEFAULT NULL,
    `category` varchar(50) NOT NULL,
    `priority` enum('low','medium','high','urgent') NOT NULL DEFAULT 'medium',
    `status` enum('open','assigned','in_progress','resolved','closed') NOT NULL DEFAULT 'open',
    `title` varchar(100) NOT NULL,
    `description` text NOT NULL,
    `assigned_to` int(11) DEFAULT NULL,
    `assigned_name` varchar(100) DEFAULT NULL,
    `location_x` float DEFAULT NULL,
    `location_y` float DEFAULT NULL,
    `location_z` float DEFAULT NULL,
    `created_at` int(11) NOT NULL,
    `updated_at` int(11) NOT NULL,
    `resolved_at` int(11) DEFAULT NULL,
    `rating` tinyint(1) DEFAULT NULL,
    `is_player_report` tinyint(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`id`),
    KEY `idx_reporter` (`reporter_license`),
    KEY `idx_assigned` (`assigned_to`),
    KEY `idx_status` (`status`),
    KEY `idx_category` (`category`),
    KEY `idx_priority` (`priority`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ticket_messages` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `ticket_id` int(11) NOT NULL,
    `sender_id` int(11) NOT NULL,
    `sender_name` varchar(100) NOT NULL,
    `message` text NOT NULL,
    `is_staff` tinyint(1) NOT NULL DEFAULT 0,
    `is_internal` tinyint(1) NOT NULL DEFAULT 0,
    `timestamp` int(11) NOT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_ticket` (`ticket_id`),
    KEY `idx_sender` (`sender_id`),
    CONSTRAINT `fk_messages_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `player_tickets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ticket_staff_stats` (
    `staff_license` varchar(100) NOT NULL,
    `staff_name` varchar(100) NOT NULL,
    `tickets_handled` int(11) NOT NULL DEFAULT 0,
    `avg_response_time` float NOT NULL DEFAULT 0,
    `total_response_time` int(11) NOT NULL DEFAULT 0,
    `last_activity` int(11) NOT NULL,
    PRIMARY KEY (`staff_license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci; 