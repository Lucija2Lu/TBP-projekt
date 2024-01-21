DROP TRIGGER IF EXISTS ZaliBiljkuTrigger ON brigamojebiljke;

DROP TRIGGER IF EXISTS IzreziBiljkuTrigger ON brigamojebiljke;

DROP FUNCTION IF EXISTS ZaliBiljku();

DROP FUNCTION IF EXISTS IzreziBiljku();

DROP FUNCTION IF EXISTS DetaljiSvihBiljki();

DROP FUNCTION IF EXISTS DetaljiBrigeBiljaka();

DROP FUNCTION IF EXISTS DetaljiBiljke();

DROP TABLE IF EXISTS BrigaMojeBiljke;

DROP TABLE IF EXISTS MojeBiljke;

DROP TABLE IF EXISTS Biljke;

DROP TABLE IF EXISTS Briga;

DROP TABLE IF EXISTS Izgled;

DROP TABLE IF EXISTS Rezanje;

DROP TABLE IF EXISTS Zalijevanje;

DROP TABLE IF EXISTS VrstaLista;

DROP TABLE IF EXISTS VrstaCvijeta;