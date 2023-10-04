CREATE DATABASE  IF NOT EXISTS `burntdvds` /*!40100 DEFAULT CHARACTER SET utf8 */;

DROP USER IF EXISTS 'burntdvds'@'%';

CREATE USER 'burntdvds'@'%' IDENTIFIED BY 'BuRnTdVdS8902348.ovusoiud';

GRANT ALL PRIVILEGES ON burntdvds.* TO 'burntdvds'@'%';

FLUSH PRIVILEGES;

USE burntdvds;

SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS `auth_http_basic_authentication`;

CREATE TABLE `auth_http_basic_authentication` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  UNIQUE KEY `username_UNIQUE` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `movies_actor`;

CREATE TABLE `movies_actor` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `imdbid` varchar(16) NOT NULL,
  `name` varchar(200) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `imdbid` (`imdbid`),
  KEY `movies_actor_name_c3a904f9` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=134088 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `movies_dvd`;

CREATE TABLE `movies_dvd` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(8) NOT NULL,
  `pino_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `movies_dvd_pino_id_0b403154_fk_movies_pino_id` (`pino_id`),
  CONSTRAINT `movies_dvd_pino_id_0b403154_fk_movies_pino_id` FOREIGN KEY (`pino_id`) REFERENCES `movies_pino` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=974 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `movies_genre`;

CREATE TABLE `movies_genre` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `movies_movie`;

CREATE TABLE `movies_movie` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `director` varchar(215) NOT NULL,
  `imdb` varchar(12) NOT NULL,
  `year` varchar(4) NOT NULL,
  `format` varchar(100) NOT NULL,
  `dvd_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `imdb_UNIQUE` (`imdb`),
  KEY `movies_movie_name_fe3aa01d` (`name`),
  KEY `movies_movie_director_fe3aa01e` (`director`),
  KEY `movies_movie_dvd_id_13c8f032_fk_movies_dvd_id` (`dvd_id`),
  KEY `movies_movie_imdb` (`imdb`) USING BTREE,
  CONSTRAINT `movies_movie_dvd_id_13c8f032_fk_movies_dvd_id` FOREIGN KEY (`dvd_id`) REFERENCES `movies_dvd` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5981 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `movies_movie_actors`;

CREATE TABLE `movies_movie_actors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `movie_id` int(11) NOT NULL,
  `actor_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `movies_movie_actors_movie_id_actor_id_73463e17_uniq` (`movie_id`,`actor_id`),
  KEY `movies_movie_actors_actor_id_44828aa1_fk_movies_actor_id` (`actor_id`),
  CONSTRAINT `movies_movie_actors_actor_id_44828aa1_fk_movies_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `movies_actor` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `movies_movie_actors_movie_id_baed65f3_fk_movies_movie_id` FOREIGN KEY (`movie_id`) REFERENCES `movies_movie` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=201984 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `movies_movie_genres`;

CREATE TABLE `movies_movie_genres` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `movie_id` int(11) NOT NULL,
  `genre_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `movies_movie_genres_movie_id_genre_id_5ff3c723_uniq` (`movie_id`,`genre_id`),
  KEY `movies_movie_genres_genre_id_c3609db2_fk_movies_genre_id` (`genre_id`),
  CONSTRAINT `movies_movie_genres_genre_id_c3609db2_fk_movies_genre_id` FOREIGN KEY (`genre_id`) REFERENCES `movies_genre` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `movies_movie_genres_movie_id_ff5e55a1_fk_movies_movie_id` FOREIGN KEY (`movie_id`) REFERENCES `movies_movie` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21556 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `movies_movie_subtitlelangs`;

CREATE TABLE `movies_movie_subtitlelangs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `movie_id` int(11) NOT NULL,
  `subtitlelang_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `movies_movie_subtitlelan_movie_id_subtitlelang_id_72f67199_uniq` (`movie_id`,`subtitlelang_id`),
  KEY `movies_movie_subtitl_subtitlelang_id_71b7d21b_fk_movies_su` (`subtitlelang_id`),
  CONSTRAINT `movies_movie_subtitl_subtitlelang_id_71b7d21b_fk_movies_su` FOREIGN KEY (`subtitlelang_id`) REFERENCES `movies_subtitlelang` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `movies_movie_subtitlelangs_movie_id_1e6aa593_fk_movies_movie_id` FOREIGN KEY (`movie_id`) REFERENCES `movies_movie` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=683 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `movies_pino`;

CREATE TABLE `movies_pino` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(8) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `movies_subtitlelang`;

CREATE TABLE `movies_subtitlelang` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `sum`;

CREATE TABLE `sum` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `x` int(11) NOT NULL,
  `y` int(11) NOT NULL,
  `sum` int(11) NOT NULL,
  `status` varchar(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

