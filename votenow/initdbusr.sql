DROP DATABASE IF EXISTS votenow;
CREATE DATABASE votenow;

GRANT USAGE ON *.* TO 'votenowusr'@'localhost';
DROP USER 'votenowusr'@'localhost';
CREATE USER 'votenowusr'@'localhost' IDENTIFIED BY 'asF,5!BC';

GRANT ALL ON votenow.* TO 'votenowusr'@'localhost';
