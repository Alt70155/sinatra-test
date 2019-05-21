-- データベースの構造
CREATE TABLE posts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  cate_id INT,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  top_picture VARCHAR(255) NOT NULL,
  PRIMARY KEY(id)
);

CREATE TABLE categories (
  cate_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  cate_name VARCHAR(255) NOT NULL,
  PRIMARY KEY(cate_id)
);

ALTER TABLE posts ADD top_picture varchar(255) NOT NULL;
