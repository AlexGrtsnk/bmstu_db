-- MySQL dump 10.13  Distrib 8.0.26, for macos10.15 (x86_64)
--
-- Host: localhost    Database: mydb
-- ------------------------------------------------------
-- Server version	8.0.26

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `userr_id` int NOT NULL,
  `fio` varchar(134) NOT NULL,
  `birthday` date NOT NULL,
  `email` varchar(134) NOT NULL,
  `passw` varchar(45) NOT NULL,
  `dateofregistration` date NOT NULL,
  `contact_phone` varchar(11) NOT NULL,
  `discount` varchar(45) NOT NULL,
  PRIMARY KEY (`userr_id`),
  UNIQUE KEY `contact_phone` (`contact_phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `managers`
--

DROP TABLE IF EXISTS `managers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `managers` (
  `manager_id` int NOT NULL,
  `fio` varchar(134) NOT NULL,
  `email` varchar(134) NOT NULL,
  `passw` varchar(45) NOT NULL,
  `acces_card` int NOT NULL,
  `contact_phone` varchar(11) NOT NULL,
  PRIMARY KEY (`manager_id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `acces_card` (`acces_card`),
  UNIQUE KEY `contact_phone` (`contact_phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `managers`
--

LOCK TABLES `managers` WRITE;
/*!40000 ALTER TABLE `managers` DISABLE KEYS */;
/*!40000 ALTER TABLE `managers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `order_id` int NOT NULL,
  `date_of_shipping` date NOT NULL,
  `addres` varchar(45) NOT NULL,
  `order_status` int NOT NULL,
  `creation_time` timestamp NOT NULL,
  `source` varchar(45) DEFAULT NULL,
  `prod_prod_id` int DEFAULT NULL,
  `cust_cust_id` int DEFAULT NULL,
  `man_man_id` int DEFAULT NULL,
  PRIMARY KEY (`order_id`),
  UNIQUE KEY `creation_time` (`creation_time`),
  KEY `prod_prod_id` (`prod_prod_id`),
  KEY `cust_cust_id` (`cust_cust_id`),
  KEY `man_man_id` (`man_man_id`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`prod_prod_id`) REFERENCES `products` (`product_id`),
  CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`cust_cust_id`) REFERENCES `customers` (`userr_id`),
  CONSTRAINT `orders_ibfk_3` FOREIGN KEY (`man_man_id`) REFERENCES `managers` (`manager_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `product_id` int NOT NULL,
  `articul` int NOT NULL,
  `nme` varchar(33) NOT NULL,
  `category` varchar(66) NOT NULL,
  `weigth` smallint NOT NULL,
  `dateofrelease` date NOT NULL,
  `price` int NOT NULL,
  PRIMARY KEY (`product_id`),
  UNIQUE KEY `articul` (`articul`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-09-19 21:33:16
