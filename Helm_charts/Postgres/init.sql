CREATE TABLE auth_user (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email VARCHAR (255) NOT NULL,
    password VARCHAR (255) NOT NULL
);

--Add Username and Password for Admin User
-- INSERT INTO auth_user (email, password) VALUES ('anyone@gmail.com', '1');
INSERT INTO auth_user (email, password) VALUES ('mohamedtharwat3551@gmail.com', 'lkdsfjk');