CREATE TABLE VrstaCvijeta (
  id_vrste SERIAL PRIMARY KEY NOT NULL,
  boja VARCHAR(25),
  velicina VARCHAR(25)
);

INSERT INTO "VrstaCvijeta" ("boja", "velicina")
VALUES
	('bijela','mali'),
	('bijela','srednji'),
	('bijela','veliki'),
	('zuti','mali'),
	('zuti','srednji'),
	('zuti','veliki'),
	('ljubicasti','mali'),
	('ljubicasti','srednji'),
	('ljubicasti','veliki'),
	('rozi','mali'),
	('rozi','srednji'),
	('rozi','veliki'),
	('narancasti','mali'),
	('narancasti','srednji'),
	('narancasti','veliki'),
	('crveni','mali'),
	('crveni','srednji'),
	('crveni','veliki');
	
CREATE TABLE VrstaLista (
  id_vrste SERIAL PRIMARY KEY NOT NULL,
  boja VARCHAR(25),
  velicina VARCHAR(25)
);

INSERT INTO "VrstaLista" ("boja", "velicina")
VALUES
	('tamnosmedi','mali'),
	('tamnosmedi','srednji'),
	('tamnosmedi','veliki'),
	('zeleni','mali'),
	('zeleni','srednji'),
	('zeleni','veliki'),
	('svjetlosmedi','mali'),
	('svjetlosmedi','srednji'),
	('svjetlosmedi','veliki'),
	('zuti','mali'),
	('zuti','srednji'),
	('zuti','veliki'),

CREATE TABLE Zalijevanje (
  id_zaljevanja SERIAL PRIMARY KEY NOT NULL,
  ucestalost integer,
  kolicina VARCHAR(25)
);

INSERT INTO Zalijevanje ("ucestalost", "kolicina")
VALUES
	(16,'malo'),
	(18,'malo'),
	(8,'umjereno'),
	(9,'umjereno'),
	(10,'umjereno'),
	(12,'umjereno'),
	(18,'umjereno'),
	(8,'puno'),
	(10,'puno');
	
CREATE TABLE Rezanje (
  id_rezanja SERIAL PRIMARY KEY NOT NULL,
  ucestalost integer,
  kolicina VARCHAR(25)
);

INSERT INTO Rezanje ("ucestalost", "kolicina")
VALUES
	(20,'suho lisce'),
	(20,'suho lisce i cvijece'),
	(25,'suho lisce'),
	(25,'suho lisce i cvijece'),
	(30,'suho lisce'),
	(30,'suho lisce i cvijece');
	
CREATE TABLE Izgled (
  id_izgleda SERIAL PRIMARY KEY NOT NULL,
  id_vrste_cvijeta INT REFERENCES VrstaCvijeta(id_vrste),
  id_vrste_lista INT REFERENCES VrstaLista(id_vrste) NOT NULL
);

 INSERT INTO Izgled ("id_vrste_cvijeta", "id_vrste_lista")
 VALUES
	(1,5),
	(2,2),
	(4,6),
	(3,3),
	(2,10),
	(1,6),
	(7,1),
	(1,7),
	(8,2),
	(NULL,11),
	(NULL,3),
	(NULL,2),
	(NULL,1),
	(NULL,7);
	
CREATE TABLE Briga (
  id_brige SERIAL PRIMARY KEY NOT NULL,
  id_zalijevanja INT REFERENCES Zalijevanje(id_zaljevanja) NOT NULL,
  id_rezanja INT REFERENCES Rezanje(id_rezanja) 
);

 INSERT INTO Briga ("id_zalijevanja", "id_rezanja")
 VALUES
	(3,6),
	(7,2),
	(3,1),
	(3,5),
	(7,5),
	(7,6),
	(5,6),
	(7,4),
	(9,4),
	(8,5),
	(6,5),
	(8,6),
	(3,2),
	(4,1),
	(2,2),
	(1,1),
	(6,1),
	(9,6);
	
CREATE TABLE Biljke (
  id_biljke SERIAL PRIMARY KEY NOT NULL,
  naziv VARCHAR(30),
  maksimalnaVelicina INTEGER,
  id_izgleda INT REFERENCES Izgled(id_izgleda),
  id_brige INT REFERENCES Briga(id_brige)
);

INSERT INTO biljke ("naziv","maksimalnavelicina","id_izgleda","id_brige")
VALUES
	('Zeleni ljiljan',45,1,1),
	('Svekrvin jezik',120,1,1),
	('Spathiphyllum',90,2,6),
	('Zlatni puzavac',300,10,3),
	('Fukus gumijevac',300,11,4),
	('Zamioculcas',75,11,5),
	('Aloe vera',60,3,6),
	('Monstera',300,4,1),
	('Lirasti fikus',300,11,7),
	('Biljka žad',90,5,8),
	('Sretni bambus',150,6,9),
	('Bostonska paprat',60,12,10),
	('Sobna palma',180,12,11),
	('Spatifilum',90,4,12),
	('Afrička ljubičica',30,7,13),
	('Filodendron',30,13,14),
	('Krunica',60,8,15),
	('Aspidistra elatior',60,11,16),
	('Kineska dolar',30,14,17),
	('Zračna biljka',30,9,18);
	
CREATE TABLE MojeBiljke (
  id_moje_biljke SERIAL PRIMARY KEY NOT NULL,
  id_biljke INT REFERENCES Biljke(id_biljke) NOT NULL,
  slika OID
);

INSERT INTO MojeBiljke ("id_biljke","slika")
VALUES
   (1),(3),(8);

CREATE TABLE BrigaMojeBiljke (
  id_brige SERIAL PRIMARY KEY NOT NULL,
  id_moje_biljke INT REFERENCES MojeBiljke(id_moje_biljke),
  datumZalijevanja DATE,
  datumRezanja DATE
);

INSERT INTO BrigaMojeBiljke ("id_moje_biljke","datumzalijevanja","datumrezanja")
VALUES 
	(2,'2023-12-15','2023-12-15'),
	(2,'2023-12-15','2023-12-15'),
	(2,'2023-12-15','2023-12-15'),
	(2,'2024-01-01',NULL),
	(2,'2024-01-20','2024-01-20'),
	(2,'2024-01-21',NULL);
	

CREATE OR REPLACE FUNCTION DetaljiBiljke(nazivBiljke VARCHAR)
RETURNS TABLE (
    maksimalna_velicina INTEGER,
    ucestalost_zalijevanja INTEGER,
    ucestalost_rezanja INTEGER,
    list_boja VARCHAR,
    list_velicina VARCHAR,
    cvijet_boja VARCHAR,
    cvijet_velicina VARCHAR
) AS
$$
BEGIN
    RETURN QUERY
    SELECT
        b."maksimalnavelicina",
        z."ucestalost" AS ucestalostzaljevanja,
        r."ucestalost" AS ucestalostrezanja,
        vl."boja" AS vrstalista_boja,
        vl."velicina" AS vrstalista_velicina,
        vc."boja" AS vrstacvijeta_boja,
        vc."velicina" AS vrstacvijeta_velicina
    FROM
        "biljke" b
    LEFT JOIN
        "izgled" i ON b."id_izgleda" = i."id_izgleda"
    LEFT JOIN
        "briga" br ON b."id_brige" = br."id_brige"
    LEFT JOIN
        "vrstalista" vl ON i."id_vrste_lista" = vl."id_vrste"
    LEFT JOIN
        "vrstacvijeta" vc ON i."id_vrste_cvijeta" = vc."id_vrste"
    LEFT JOIN
        "zalijevanje" z ON br."id_zalijevanja" = z."id_zaljevanja"
    LEFT JOIN
        "rezanje" r ON br."id_rezanja" = r."id_rezanja"
    WHERE
        b."naziv" = nazivBiljke;

    RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION DetaljiBrigeBiljaka()
RETURNS TABLE (
	naziv_biljke VARCHAR,
	datum_zalijevanja DATE,
	datum_rezanja DATE
) AS
$$
BEGIN
    RETURN QUERY
    SELECT
		b."naziv",
		bm."datumzalijevanja",
		bm."datumrezanja"		
    FROM
        "brigamojebiljke" bm
	JOIN "mojebiljke" mb ON bm."id_moje_biljke" = mb."id_moje_biljke"
    JOIN "biljke" b ON mb."id_biljke" = b."id_biljke";    
    RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION DetaljiSvihBiljki()
RETURNS TABLE (
	naziv_biljke VARCHAR,
    maksimalna_velicina INTEGER,
    ucestalost_zalijevanja INTEGER,
    ucestalost_rezanja INTEGER,
    list_boja VARCHAR,
    list_velicina VARCHAR,
    cvijet_boja VARCHAR,
    cvijet_velicina VARCHAR
) AS
$$
BEGIN
    RETURN QUERY
    SELECT
		b."naziv",
        b."maksimalnavelicina",
        z."ucestalost" AS ucestalostzaljevanja,
        r."ucestalost" AS ucestalostrezanja,
        vl."boja" AS vrstalista_boja,
        vl."velicina" AS vrstalista_velicina,
        vc."boja" AS vrstacvijeta_boja,
        vc."velicina" AS vrstacvijeta_velicina
    FROM
        "biljke" b
    LEFT JOIN
        "izgled" i ON b."id_izgleda" = i."id_izgleda"
    LEFT JOIN
        "briga" br ON b."id_brige" = br."id_brige"
    LEFT JOIN
        "vrstalista" vl ON i."id_vrste_lista" = vl."id_vrste"
    LEFT JOIN
        "vrstacvijeta" vc ON i."id_vrste_cvijeta" = vc."id_vrste"
    LEFT JOIN
        "zalijevanje" z ON br."id_zalijevanja" = z."id_zaljevanja"
    LEFT JOIN
        "rezanje" r ON br."id_rezanja" = r."id_rezanja";

    RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION IzreziBiljku()
RETURNS TRIGGER AS
$$
DECLARE
    zadnjerezanja DATE;
    ucestalostrezanja INT;
    danaodrezanja INT;
BEGIN
    SELECT bm."datumrezanja", r."ucestalost"
    INTO zadnjerezanja, ucestalostrezanja
    FROM "mojebiljke" mb
    JOIN "biljke" b ON mb."id_biljke" = b."id_biljke"
    JOIN "brigamojebiljke" bm ON mb."id_moje_biljke" = bm."id_moje_biljke"
    JOIN "rezanje" r ON r."id_rezanja" = r."id_rezanja"
    WHERE mb."id_moje_biljke" = NEW."id_moje_biljke"
    ORDER BY bm."datumrezanja" DESC
    LIMIT 1;

    danaodrezanja := CURRENT_DATE - zadnjerezanja;

    IF danaodrezanja >= ucestalostrezanja OR danaodrezanja IS NULL THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'Biljku ne treba jos rezati!';
    END IF;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER IzreziBiljkuTrigger
BEFORE UPDATE ON brigamojebiljke
FOR EACH ROW
EXECUTE FUNCTION IzreziBiljku();

CREATE OR REPLACE FUNCTION ZaliBiljku()
RETURNS TRIGGER AS
$$
DECLARE
    zadnjezalijevanje DATE;
    ucestalostzalijevanja INT;
    danaodzalijevanja INT;
BEGIN
    SELECT bm."datumzalijevanja", z."ucestalost"
    INTO zadnjezalijevanje, ucestalostzalijevanja
    FROM "mojebiljke" mb
    JOIN "biljke" b ON mb."id_biljke" = b."id_biljke"
    JOIN "brigamojebiljke" bm ON mb."id_moje_biljke" = bm."id_moje_biljke"
    JOIN "zalijevanje" z ON z."id_zaljevanja" = z."id_zaljevanja"
    WHERE mb."id_moje_biljke" = NEW."id_moje_biljke"
    ORDER BY bm."datumzalijevanja" DESC
    LIMIT 1;

    danaodzalijevanja := CURRENT_DATE - zadnjezalijevanje;

    IF danaodzalijevanja >= ucestalostzalijevanja THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'Biljku ne treba jos zaliti!';
    END IF;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER ZaliBiljkuTrigger
BEFORE INSERT ON brigamojebiljke
FOR EACH ROW
EXECUTE FUNCTION ZaliBiljku();