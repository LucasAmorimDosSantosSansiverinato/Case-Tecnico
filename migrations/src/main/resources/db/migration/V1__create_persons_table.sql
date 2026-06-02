CREATE TABLE IF NOT EXISTS persons (
    id           UUID         PRIMARY KEY,
    full_name    VARCHAR(255) NOT NULL,
    document     VARCHAR(11)  NOT NULL UNIQUE,
    email        VARCHAR(255) NOT NULL UNIQUE,
    birth_date   DATE         NOT NULL,
    cep          VARCHAR(8)   NOT NULL,
    street       VARCHAR(255) NOT NULL,
    neighborhood VARCHAR(255),
    city         VARCHAR(255) NOT NULL,
    state        VARCHAR(2)   NOT NULL,
    complement   VARCHAR(255),
    number       VARCHAR(20),
    login        VARCHAR(7)   NOT NULL UNIQUE,
    created_at   TIMESTAMP    NOT NULL DEFAULT NOW()
);
