PGDMP     ,                     |            TBP-Projekt    15.3    15.3 R    Y           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            Z           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            [           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            \           1262    25003    TBP-Projekt    DATABASE     �   CREATE DATABASE "TBP-Projekt" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';
    DROP DATABASE "TBP-Projekt";
                postgres    false            �            1255    25274     detaljibiljke(character varying)    FUNCTION     �  CREATE FUNCTION public.detaljibiljke(nazivbiljke character varying) RETURNS TABLE(maksimalna_velicina integer, ucestalost_zalijevanja integer, ucestalost_rezanja integer, list_boja character varying, list_velicina character varying, cvijet_boja character varying, cvijet_velicina character varying)
    LANGUAGE plpgsql
    AS $$
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
$$;
 C   DROP FUNCTION public.detaljibiljke(nazivbiljke character varying);
       public          postgres    false            �            1255    25537    detaljibrigebiljaka()    FUNCTION     �  CREATE FUNCTION public.detaljibrigebiljaka() RETURNS TABLE(naziv_biljke character varying, datum_zalijevanja date, datum_rezanja date)
    LANGUAGE plpgsql
    AS $$
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
$$;
 ,   DROP FUNCTION public.detaljibrigebiljaka();
       public          postgres    false            �            1255    25398    detaljisvihbiljki()    FUNCTION     �  CREATE FUNCTION public.detaljisvihbiljki() RETURNS TABLE(naziv_biljke character varying, maksimalna_velicina integer, ucestalost_zalijevanja integer, ucestalost_rezanja integer, list_boja character varying, list_velicina character varying, cvijet_boja character varying, cvijet_velicina character varying)
    LANGUAGE plpgsql
    AS $$
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
$$;
 *   DROP FUNCTION public.detaljisvihbiljki();
       public          postgres    false            �            1255    25266    izrezibiljku()    FUNCTION       CREATE FUNCTION public.izrezibiljku() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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

    IF danaodrezanja >= ucestalostrezanja THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'Biljku ne treba jos rezati!';
    END IF;
    RETURN NEW;
END;
$$;
 %   DROP FUNCTION public.izrezibiljku();
       public          postgres    false            �            1255    25262    zalibiljku()    FUNCTION     M  CREATE FUNCTION public.zalibiljku() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;
 #   DROP FUNCTION public.zalibiljku();
       public          postgres    false            �            1259    25105    biljke    TABLE     �   CREATE TABLE public.biljke (
    id_biljke integer NOT NULL,
    naziv character varying(30),
    maksimalnavelicina integer,
    id_izgleda integer,
    id_brige integer
);
    DROP TABLE public.biljke;
       public         heap    postgres    false            �            1259    25104    biljke_id_biljke_seq    SEQUENCE     �   CREATE SEQUENCE public.biljke_id_biljke_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.biljke_id_biljke_seq;
       public          postgres    false    227            ]           0    0    biljke_id_biljke_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.biljke_id_biljke_seq OWNED BY public.biljke.id_biljke;
          public          postgres    false    226            �            1259    25088    briga    TABLE     z   CREATE TABLE public.briga (
    id_brige integer NOT NULL,
    id_zalijevanja integer NOT NULL,
    id_rezanja integer
);
    DROP TABLE public.briga;
       public         heap    postgres    false            �            1259    25087    briga_id_brige_seq    SEQUENCE     �   CREATE SEQUENCE public.briga_id_brige_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.briga_id_brige_seq;
       public          postgres    false    225            ^           0    0    briga_id_brige_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.briga_id_brige_seq OWNED BY public.briga.id_brige;
          public          postgres    false    224            �            1259    25136    brigamojebiljke    TABLE     �   CREATE TABLE public.brigamojebiljke (
    id_brige integer NOT NULL,
    id_moje_biljke integer,
    datumzalijevanja date,
    datumrezanja date
);
 #   DROP TABLE public.brigamojebiljke;
       public         heap    postgres    false            �            1259    25135    brigamojebiljke_id_brige_seq    SEQUENCE     �   CREATE SEQUENCE public.brigamojebiljke_id_brige_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.brigamojebiljke_id_brige_seq;
       public          postgres    false    231            _           0    0    brigamojebiljke_id_brige_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.brigamojebiljke_id_brige_seq OWNED BY public.brigamojebiljke.id_brige;
          public          postgres    false    230            �            1259    25071    izgled    TABLE     �   CREATE TABLE public.izgled (
    id_izgleda integer NOT NULL,
    id_vrste_cvijeta integer,
    id_vrste_lista integer NOT NULL
);
    DROP TABLE public.izgled;
       public         heap    postgres    false            �            1259    25070    izgled_id_izgleda_seq    SEQUENCE     �   CREATE SEQUENCE public.izgled_id_izgleda_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.izgled_id_izgleda_seq;
       public          postgres    false    223            `           0    0    izgled_id_izgleda_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.izgled_id_izgleda_seq OWNED BY public.izgled.id_izgleda;
          public          postgres    false    222            �            1259    25122 
   mojebiljke    TABLE     y   CREATE TABLE public.mojebiljke (
    id_moje_biljke integer NOT NULL,
    id_biljke integer NOT NULL,
    slika bytea
);
    DROP TABLE public.mojebiljke;
       public         heap    postgres    false            �            1259    25121    mojebiljke_id_moje_biljke_seq    SEQUENCE     �   CREATE SEQUENCE public.mojebiljke_id_moje_biljke_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.mojebiljke_id_moje_biljke_seq;
       public          postgres    false    229            a           0    0    mojebiljke_id_moje_biljke_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.mojebiljke_id_moje_biljke_seq OWNED BY public.mojebiljke.id_moje_biljke;
          public          postgres    false    228            �            1259    25052    rezanje    TABLE     }   CREATE TABLE public.rezanje (
    id_rezanja integer NOT NULL,
    ucestalost integer,
    kolicina character varying(25)
);
    DROP TABLE public.rezanje;
       public         heap    postgres    false            �            1259    25051    rezanje_id_rezanja_seq    SEQUENCE     �   CREATE SEQUENCE public.rezanje_id_rezanja_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.rezanje_id_rezanja_seq;
       public          postgres    false    221            b           0    0    rezanje_id_rezanja_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.rezanje_id_rezanja_seq OWNED BY public.rezanje.id_rezanja;
          public          postgres    false    220            �            1259    25031    vrstacvijeta    TABLE     �   CREATE TABLE public.vrstacvijeta (
    id_vrste integer NOT NULL,
    boja character varying(25),
    velicina character varying(25)
);
     DROP TABLE public.vrstacvijeta;
       public         heap    postgres    false            �            1259    25030    vrstacvijeta_id_vrste_seq    SEQUENCE     �   CREATE SEQUENCE public.vrstacvijeta_id_vrste_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.vrstacvijeta_id_vrste_seq;
       public          postgres    false    215            c           0    0    vrstacvijeta_id_vrste_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.vrstacvijeta_id_vrste_seq OWNED BY public.vrstacvijeta.id_vrste;
          public          postgres    false    214            �            1259    25038 
   vrstalista    TABLE     �   CREATE TABLE public.vrstalista (
    id_vrste integer NOT NULL,
    boja character varying(25),
    velicina character varying(25)
);
    DROP TABLE public.vrstalista;
       public         heap    postgres    false            �            1259    25037    vrstalista_id_vrste_seq    SEQUENCE     �   CREATE SEQUENCE public.vrstalista_id_vrste_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.vrstalista_id_vrste_seq;
       public          postgres    false    217            d           0    0    vrstalista_id_vrste_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.vrstalista_id_vrste_seq OWNED BY public.vrstalista.id_vrste;
          public          postgres    false    216            �            1259    25045    zalijevanje    TABLE     �   CREATE TABLE public.zalijevanje (
    id_zaljevanja integer NOT NULL,
    ucestalost integer,
    kolicina character varying(25)
);
    DROP TABLE public.zalijevanje;
       public         heap    postgres    false            �            1259    25044    zalijevanje_id_zaljevanja_seq    SEQUENCE     �   CREATE SEQUENCE public.zalijevanje_id_zaljevanja_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.zalijevanje_id_zaljevanja_seq;
       public          postgres    false    219            e           0    0    zalijevanje_id_zaljevanja_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.zalijevanje_id_zaljevanja_seq OWNED BY public.zalijevanje.id_zaljevanja;
          public          postgres    false    218            �           2604    25108    biljke id_biljke    DEFAULT     t   ALTER TABLE ONLY public.biljke ALTER COLUMN id_biljke SET DEFAULT nextval('public.biljke_id_biljke_seq'::regclass);
 ?   ALTER TABLE public.biljke ALTER COLUMN id_biljke DROP DEFAULT;
       public          postgres    false    226    227    227            �           2604    25091    briga id_brige    DEFAULT     p   ALTER TABLE ONLY public.briga ALTER COLUMN id_brige SET DEFAULT nextval('public.briga_id_brige_seq'::regclass);
 =   ALTER TABLE public.briga ALTER COLUMN id_brige DROP DEFAULT;
       public          postgres    false    224    225    225            �           2604    25139    brigamojebiljke id_brige    DEFAULT     �   ALTER TABLE ONLY public.brigamojebiljke ALTER COLUMN id_brige SET DEFAULT nextval('public.brigamojebiljke_id_brige_seq'::regclass);
 G   ALTER TABLE public.brigamojebiljke ALTER COLUMN id_brige DROP DEFAULT;
       public          postgres    false    230    231    231            �           2604    25074    izgled id_izgleda    DEFAULT     v   ALTER TABLE ONLY public.izgled ALTER COLUMN id_izgleda SET DEFAULT nextval('public.izgled_id_izgleda_seq'::regclass);
 @   ALTER TABLE public.izgled ALTER COLUMN id_izgleda DROP DEFAULT;
       public          postgres    false    222    223    223            �           2604    25125    mojebiljke id_moje_biljke    DEFAULT     �   ALTER TABLE ONLY public.mojebiljke ALTER COLUMN id_moje_biljke SET DEFAULT nextval('public.mojebiljke_id_moje_biljke_seq'::regclass);
 H   ALTER TABLE public.mojebiljke ALTER COLUMN id_moje_biljke DROP DEFAULT;
       public          postgres    false    229    228    229            �           2604    25055    rezanje id_rezanja    DEFAULT     x   ALTER TABLE ONLY public.rezanje ALTER COLUMN id_rezanja SET DEFAULT nextval('public.rezanje_id_rezanja_seq'::regclass);
 A   ALTER TABLE public.rezanje ALTER COLUMN id_rezanja DROP DEFAULT;
       public          postgres    false    220    221    221            �           2604    25034    vrstacvijeta id_vrste    DEFAULT     ~   ALTER TABLE ONLY public.vrstacvijeta ALTER COLUMN id_vrste SET DEFAULT nextval('public.vrstacvijeta_id_vrste_seq'::regclass);
 D   ALTER TABLE public.vrstacvijeta ALTER COLUMN id_vrste DROP DEFAULT;
       public          postgres    false    214    215    215            �           2604    25041    vrstalista id_vrste    DEFAULT     z   ALTER TABLE ONLY public.vrstalista ALTER COLUMN id_vrste SET DEFAULT nextval('public.vrstalista_id_vrste_seq'::regclass);
 B   ALTER TABLE public.vrstalista ALTER COLUMN id_vrste DROP DEFAULT;
       public          postgres    false    216    217    217            �           2604    25048    zalijevanje id_zaljevanja    DEFAULT     �   ALTER TABLE ONLY public.zalijevanje ALTER COLUMN id_zaljevanja SET DEFAULT nextval('public.zalijevanje_id_zaljevanja_seq'::regclass);
 H   ALTER TABLE public.zalijevanje ALTER COLUMN id_zaljevanja DROP DEFAULT;
       public          postgres    false    218    219    219            R          0    25105    biljke 
   TABLE DATA                 public          postgres    false    227   	l       P          0    25088    briga 
   TABLE DATA                 public          postgres    false    225   n       V          0    25136    brigamojebiljke 
   TABLE DATA                 public          postgres    false    231   �n       N          0    25071    izgled 
   TABLE DATA                 public          postgres    false    223   �o       T          0    25122 
   mojebiljke 
   TABLE DATA                 public          postgres    false    229   Vp       L          0    25052    rezanje 
   TABLE DATA                 public          postgres    false    221   �~      F          0    25031    vrstacvijeta 
   TABLE DATA                 public          postgres    false    215   q      H          0    25038 
   vrstalista 
   TABLE DATA                 public          postgres    false    217   _�      J          0    25045    zalijevanje 
   TABLE DATA                 public          postgres    false    219   *�      f           0    0    biljke_id_biljke_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.biljke_id_biljke_seq', 20, true);
          public          postgres    false    226            g           0    0    briga_id_brige_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.briga_id_brige_seq', 18, true);
          public          postgres    false    224            h           0    0    brigamojebiljke_id_brige_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.brigamojebiljke_id_brige_seq', 11, true);
          public          postgres    false    230            i           0    0    izgled_id_izgleda_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.izgled_id_izgleda_seq', 14, true);
          public          postgres    false    222            j           0    0    mojebiljke_id_moje_biljke_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.mojebiljke_id_moje_biljke_seq', 3, true);
          public          postgres    false    228            k           0    0    rezanje_id_rezanja_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.rezanje_id_rezanja_seq', 6, true);
          public          postgres    false    220            l           0    0    vrstacvijeta_id_vrste_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.vrstacvijeta_id_vrste_seq', 18, true);
          public          postgres    false    214            m           0    0    vrstalista_id_vrste_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.vrstalista_id_vrste_seq', 12, true);
          public          postgres    false    216            n           0    0    zalijevanje_id_zaljevanja_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.zalijevanje_id_zaljevanja_seq', 9, true);
          public          postgres    false    218            �           2606    25110    biljke biljke_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.biljke
    ADD CONSTRAINT biljke_pkey PRIMARY KEY (id_biljke);
 <   ALTER TABLE ONLY public.biljke DROP CONSTRAINT biljke_pkey;
       public            postgres    false    227            �           2606    25093    briga briga_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.briga
    ADD CONSTRAINT briga_pkey PRIMARY KEY (id_brige);
 :   ALTER TABLE ONLY public.briga DROP CONSTRAINT briga_pkey;
       public            postgres    false    225            �           2606    25141 $   brigamojebiljke brigamojebiljke_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.brigamojebiljke
    ADD CONSTRAINT brigamojebiljke_pkey PRIMARY KEY (id_brige);
 N   ALTER TABLE ONLY public.brigamojebiljke DROP CONSTRAINT brigamojebiljke_pkey;
       public            postgres    false    231            �           2606    25076    izgled izgled_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.izgled
    ADD CONSTRAINT izgled_pkey PRIMARY KEY (id_izgleda);
 <   ALTER TABLE ONLY public.izgled DROP CONSTRAINT izgled_pkey;
       public            postgres    false    223            �           2606    25129    mojebiljke mojebiljke_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.mojebiljke
    ADD CONSTRAINT mojebiljke_pkey PRIMARY KEY (id_moje_biljke);
 D   ALTER TABLE ONLY public.mojebiljke DROP CONSTRAINT mojebiljke_pkey;
       public            postgres    false    229            �           2606    25057    rezanje rezanje_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.rezanje
    ADD CONSTRAINT rezanje_pkey PRIMARY KEY (id_rezanja);
 >   ALTER TABLE ONLY public.rezanje DROP CONSTRAINT rezanje_pkey;
       public            postgres    false    221            �           2606    25036    vrstacvijeta vrstacvijeta_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.vrstacvijeta
    ADD CONSTRAINT vrstacvijeta_pkey PRIMARY KEY (id_vrste);
 H   ALTER TABLE ONLY public.vrstacvijeta DROP CONSTRAINT vrstacvijeta_pkey;
       public            postgres    false    215            �           2606    25043    vrstalista vrstalista_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.vrstalista
    ADD CONSTRAINT vrstalista_pkey PRIMARY KEY (id_vrste);
 D   ALTER TABLE ONLY public.vrstalista DROP CONSTRAINT vrstalista_pkey;
       public            postgres    false    217            �           2606    25050    zalijevanje zalijevanje_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.zalijevanje
    ADD CONSTRAINT zalijevanje_pkey PRIMARY KEY (id_zaljevanja);
 F   ALTER TABLE ONLY public.zalijevanje DROP CONSTRAINT zalijevanje_pkey;
       public            postgres    false    219            �           2620    25279 #   brigamojebiljke izrezibiljkutrigger    TRIGGER     �   CREATE TRIGGER izrezibiljkutrigger BEFORE UPDATE ON public.brigamojebiljke FOR EACH ROW EXECUTE FUNCTION public.izrezibiljku();
 <   DROP TRIGGER izrezibiljkutrigger ON public.brigamojebiljke;
       public          postgres    false    233    231            �           2620    25263 !   brigamojebiljke zalibiljkutrigger    TRIGGER     |   CREATE TRIGGER zalibiljkutrigger BEFORE INSERT ON public.brigamojebiljke FOR EACH ROW EXECUTE FUNCTION public.zalibiljku();
 :   DROP TRIGGER zalibiljkutrigger ON public.brigamojebiljke;
       public          postgres    false    232    231            �           2606    25116    biljke biljke_id_brige_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.biljke
    ADD CONSTRAINT biljke_id_brige_fkey FOREIGN KEY (id_brige) REFERENCES public.briga(id_brige);
 E   ALTER TABLE ONLY public.biljke DROP CONSTRAINT biljke_id_brige_fkey;
       public          postgres    false    227    3238    225            �           2606    25111    biljke biljke_id_izgleda_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.biljke
    ADD CONSTRAINT biljke_id_izgleda_fkey FOREIGN KEY (id_izgleda) REFERENCES public.izgled(id_izgleda);
 G   ALTER TABLE ONLY public.biljke DROP CONSTRAINT biljke_id_izgleda_fkey;
       public          postgres    false    223    227    3236            �           2606    25099    briga briga_id_rezanja_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.briga
    ADD CONSTRAINT briga_id_rezanja_fkey FOREIGN KEY (id_rezanja) REFERENCES public.rezanje(id_rezanja);
 E   ALTER TABLE ONLY public.briga DROP CONSTRAINT briga_id_rezanja_fkey;
       public          postgres    false    221    225    3234            �           2606    25094    briga briga_id_zalijevanja_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.briga
    ADD CONSTRAINT briga_id_zalijevanja_fkey FOREIGN KEY (id_zalijevanja) REFERENCES public.zalijevanje(id_zaljevanja);
 I   ALTER TABLE ONLY public.briga DROP CONSTRAINT briga_id_zalijevanja_fkey;
       public          postgres    false    219    3232    225            �           2606    25142 3   brigamojebiljke brigamojebiljke_id_moje_biljke_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.brigamojebiljke
    ADD CONSTRAINT brigamojebiljke_id_moje_biljke_fkey FOREIGN KEY (id_moje_biljke) REFERENCES public.mojebiljke(id_moje_biljke);
 ]   ALTER TABLE ONLY public.brigamojebiljke DROP CONSTRAINT brigamojebiljke_id_moje_biljke_fkey;
       public          postgres    false    229    231    3242            �           2606    25077 #   izgled izgled_id_vrste_cvijeta_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.izgled
    ADD CONSTRAINT izgled_id_vrste_cvijeta_fkey FOREIGN KEY (id_vrste_cvijeta) REFERENCES public.vrstacvijeta(id_vrste);
 M   ALTER TABLE ONLY public.izgled DROP CONSTRAINT izgled_id_vrste_cvijeta_fkey;
       public          postgres    false    3228    223    215            �           2606    25082 !   izgled izgled_id_vrste_lista_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.izgled
    ADD CONSTRAINT izgled_id_vrste_lista_fkey FOREIGN KEY (id_vrste_lista) REFERENCES public.vrstalista(id_vrste);
 K   ALTER TABLE ONLY public.izgled DROP CONSTRAINT izgled_id_vrste_lista_fkey;
       public          postgres    false    217    3230    223            �           2606    25130 $   mojebiljke mojebiljke_id_biljke_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mojebiljke
    ADD CONSTRAINT mojebiljke_id_biljke_fkey FOREIGN KEY (id_biljke) REFERENCES public.biljke(id_biljke);
 N   ALTER TABLE ONLY public.mojebiljke DROP CONSTRAINT mojebiljke_id_biljke_fkey;
       public          postgres    false    227    3240    229            R   �  x����j�0��y
�܂)Q��qW)��M{�\ƶ��-KF��;�����:'ܾ��0,��9��q{��"6�/O�����*E]�J\`��_����XTP6X�6�)ډbA���*�שý�����7[q!c�)�
]�a`�X$�X�y�k�?!��S��ЈB�$���C�̯�}���Ck_~Et�k><=��kh���?@�c�==�� ��[_�F�}���Y	�_��[ ����/f=|6<|A�Jt����� �/��`M���cǓ �_�4-���?_�ggG�|
�!?�� ��:��B�o/g�'��9�mӒ�t�j��x�N��p�<����'�g~ �䔹�������s�w�>����)�0�g��OU�]ɩw�����Κ���2Wr��9o�����<Ȝ{���ցP��C����� �+9��(���jpg؅2��o�7_�4����\�0R��7o�5�      P   �   x����
�@��<Ŗ	,�^���H�&�ʩA.��yz��W�n�����i��9�vÑޟ����➖b���42����M�׾&��e\CN�?���baJ��d� �a*����� ��s 1�_#����A,�R�H��j,Q�L��)�H���r���'�NQ�I���F���6EVz��(��{Ԃ      V   �   x���v
Q���W((M��L�K*�LO���JM����NU��L����( Y �x���BJbIinUbNfVjYb^V"T�(�
��Ts�	uV�0�Q0�QP7202�54�54UG�iZsy��!@W
��(
���b�k`D@���������v���:*�~Qb�FHA�� ���i      N   �   x����
�P�Oq�
C8�K�.1Hm+�7\D�����a� �b����ܓ�Er*�����eP�N��C��T]�Y����8�u;�[?��j��CV%L&�񭽑��v�H�.�#�v��J���v���H"!AK��zu(AǄH�}l�*���"�0o�H��x�t�o:"���Km�ٛ�f      T      x���K�,͚�7���3KИ8gy��@���<2��CBK26���+j����-�{���U�����9ſ���/����������������_���?����_��?���������������?��x��_����_���������%��_�����������_�S]�K���ƿ�����/�����}'�CyK+����������{�����6��e�e�����_�W!F�~�����{�+&?������_�?���y�	���Z�G���~~B���yJ:����!�������6�T���G�����~����3���vX���%V��w������:߰��嘞���7�s�O~�/�4�WJ�r/9�<���;��[��m����y=U��5����}��=$�;'�&&�!Ee"�'�b��g��y�#5���Ev1#���o��0�}{���xW�}��˟}�>���͕[A2Jd{s�-�'�Ա���/��؄W��&6&$���'��7�'޷��~��ejn<w?J.�Tt�)}xk��֊�^G}[n�����ԅ�e+O}��<�����^{�O�}�w��Gu��>�x_����/~y��N�b�Yg���s�w��WYu�����z%T�����q>�T��9���*v"�կ}�׿�ۯxu-���߯�g���#���m������
��k�[�U�J��t�B��$���
#�k��۲�{�ޕS���v�?��?厥���ܱ����Z�u��y�g�hܗk8o-�<�l��������%V�î�<[�n����O�Ki��c��w�o�ҙ����%��[[���Q���07O�%}����>|��y��7q���^�xˈ�e��g������?>�V�&|���Թ�Ã=�N��/</vz�^����qf�{dv�u7�����,�xv���Mk̵0��,d	|^,�9x���a�Zj�e{����U�����:m||�ͅ���˝:�1>Ϛ<ٷ�^�<Bk�T��g�3W����aK�wq�VN*�CD���
?irW�3�/|������~+��%���ZcQ&����8�yX�wk�r8\fY,LdZ���}��y��N�ث <Vц����zD	Y�>�Eۉo�u�~�?u�����r���/,mz�g56������<�mq��}��ٲ&׊�@��^�7oF�?�q�2���F��Т��x_.u�Mر�v�κ�dEb�L�1��"B��X�V��;z�ibo�x���=G�}��O/�u������q����Nxv�|lQ��<?�N��[�|������H�)�kv��=��?ͲtD�7>v�� ��pS��p�н4
v��� �F.�KaC��.�mCA��Dl��g�q!��ۜ/�QR>�Xq�{��"�RP��h��uc��7�rv�{�U�!����x��|��]�QJ\��`ޔ䫦��u�b~Ok��ņ"�"�X��V+��6+�����V���Mw�KErй�"���w�qP�JF8��i�8sa�7��\�H�>�"��|����$���I V��)�`?
X������ ���Z�'Ł+��o����ڕ��4��b��������Z>~#.�LD(}�S��-���g�[MF�í�?_D1��ĉ���b�|������GT����GAa��ۻ��4r������VĮ�|���AޙK���w���tqpo@Y�'iZ{Բ��.P��.*2�����+���j����Z�ul��;f�]4`AB�2�j N��#����ۧyw�a�n�:A���`�Ɍ,|î���7K�+�}�<�7����|����0��8
�B�::U��-.F��  ?�1�[\kN�d�G��1f'g�H��p)}X��'@5Ý�r[�Z/OM+P�*!�D��������k��_�ʷ����>K��V�$���=W�[�{޸�ۊ�pG�ڽi��T�������w]i�o�𕯯���mo�<�������c��9L�6
V��0���?�9�",.A,�D-P�O���$�o��7QZ�����iB��|+�y���Ƈrg��x;�d��>a}�	 ��Iu��3����y:"�fy7kb�p�ט7� ���l�����@aO�y%~�p���'����G�# 2���5}�7[�F�������^�z
4�����㗵�p�Ĺ�ŗW "B쿢2�3��4��Ĺ��YOc�F ����k�~ˣ�]#��j�o`b��w�~�2�|b��!;�F�9���aAv�@m�o��
��(}����#:�M9������#W�m��DXꡯ��Z-Z�  ��z��Ӕ��AÊ��{ZB&�� �!��DĀ��kw�@��1���g��q���@%���^g?y�*� �cz*Q��{#�Vj�w)�/�[iד���Gd�La�)�z��b >ˉ�⫀���F��[���;�$����m�gʁY�+:�*�UZ�`g��������|�-�x�E���V4@�y$}a����`�Av-������n!C�v�Ҥ]x�~o�"l��D���N���i�%#���+�H�mǎ�2ў�5�l�H2O�mƯ%�����\��|W�gO�mL�����=k�o�Y���y�`5�,B}����>���p�<��qO���G),�;�
����\%����O�V����#P?��Zp����T�)�"w�{�{�tR`�ʸ��d�o@~��{F��	Y� :�@�:��	U�YpZ�)��,N���l�����A��3|�/������atň���,i�%����8��#4(/��:��yf$�p�k�ہf��>�wDp�Y>Ծc9;��� 좒��K
��W����ؿGV�m/h�8u�S^�h�ow�4`߇w��)���1����$C�-���w^�bn�f$��bCq�L�!ߏ3�0��z��:@ˈ;������cP���%��"ym��
h�1V��@�^ތ�B�A��7�s��w�gE��^�����A�!�%\���%H�*�>\3�ǚcx
��LL�7.��ƙ���b _�~s����ZU9�xX���\j���5o���m���1�����Ӵuj��g�u�uL�x�e�,R��#��5���wY���~�j�g����t��r�Kн�[�5LOh��1a]�E��D5Nl�һM����������]d[���� la�6C���@-�#w�JyƂh�4���<^E7^�?L��?-��n� �R��Y��0ڑ
n�G�2�]Pׅ/'�91n,q@�w9`�>�8����(k-N~�X_�Cn�ClP2p��]���>�\5���Ϡ�KX���(�4YX����F�0aC�%�/ޛ��H�}ND�#�V�WC�W��	���eƬb�� �q��v��	���n�ۂu��qj3��1�P�~`X/�m<��B\Uv?*��t�	L)�nL��������0z#��ǃ .c"8d&��wo|���<	׉�XX���Շ���ʪ�*+�Y��<�F���b1@��y@� ����{wh���v�hg�
 c�}J�˅g��3���w|gl.
r� �S������� �<����G�� D����[?h(��-Bcq�0�	�f����d�$e�d �~2�PC:@�8��q��� ��;��~_�y�������nw<f7�xbR��t������6՜1J�Ŕ倠4KF�a@��M$��Z�/v��5J�
�-î������#�e�ϻ 0W:#T���9)��{��U�ʣoJ^�uf�����˹�溤�'�P�!����:ި6�����k��G�Iq��@�k�(i�J�Iу!��'�B��� ByD<�?�7�R�6<v*B��ǐt�|���|r�-������t��!7>���l H�y�]Wz�����Գ��
qDZ1���ɮ���p�{�G}{���>��A�����~�    %a��������bk��"�#Έ
�Q�c��2#�|/�/���2��=������vo���MH>��j5.�b�w�?poy��ȯ`Ѡ7�%��@�1o׍ts4Z�#	`=5��[�<!f��	���Wt �d��.+A�y6�����E�������.�(���!�20���,r����qx?�$؄}��P7��K�hc���R\�g��\
�c��ă��,N��ײ-�3X8v5�6dL �<)�L�����j�E��Lf���W������༊�'�ϕ��_~���2��ö���c*�s�Ǎ�
��!oB~E#貁f�P�OlOń�l�v�L�")�]8דї��%��&>@��+���+��Ծ�|Xc]D��>kx���e<�3>)�NR)o���yT��d����l��8�Ϛ� +m�C���}F�Sn�����;T�PlX��qJpVaز~�U��<[�+e,ڸ2�e&0Ml�s=&o?�m��T��]]x5D�~t?g��cK�H0�.�G���~��C��[�׾��̃�>�8�59���N���b�J)B�G�x��Ni��ǆ�9��c6�7�� Q3�`��X�{���� �a��LP�h��y�/Q�c�0P���t^����`BL�cԂS�#x�\Rm0���0%P,�1½� �L_�Ƈ�����p�>!,���g�� .LB�w��@g���oXz׳�d�m�|�"�&|0�Q��:��a��(�F�&�q����e���-�r�����T*68xuf��������V5��-�bG؍Q�ݧnuQr�U_����|k�%�:�(�"�y�t��n��[�ݻ
預�{X�njI�ƠA�_n|�0S ��/(=�.#��������^%.�� 8|��zW�0�b ;[�!�l&`"�r���U���0���X?�}�"SO
-:̣�/�5t`\�`� r���.0ySr�fj���-��� �{3P�¡��<��o�c<���KXy^4��A�@�Ze���KÌ�Q3)O5��� (�$?<�._ç�?���x�ғ��W��38r�X:l+����Lp2`.��`?+W�(���j��ѡŎD�F��Q�����A�6,����R:a��^y��b3@�M�`�?�����1��{�CXKu`��Feʾ(��r��@�7)����:�.E���d��~q�7頌�i=1��Su�p�P`}|�&\�6Cl�Au���!�滸%T(޺(�����q�p<KL ���2�$�4�
t�,�6w�&Z�,.?�\x}7��;\{�sT��X@�Yǘ����0�@�84ߔX�g[LX�Ѳ�;�l]ˍǍ�_�RD�%u��%�D�nԸ�R���l=l�yCc�O2���P�=��UZ��}>q��������͒f�k����$�cC�h�4W�j�~^gjL
@ﰘ* J�.�:�g��a�+� a״��b#�+�OB��6�%u=��@;�F���@O������,�H�	_�3Y�F6��@6���V���rY	�p��x<��8������S#?Oi�\��� �ia͆����Z�����9�}D�q6i��b��Dp'D�g5e�/Nml���n�ހF_Oz,��I#Dk%� @��0���_B2�}&��5���da�7�'��tqm��N,�L�ouc<˚�db+�7������>��|D� 6
�M˾�z/�	�E��>�����&fM��=. �e�?��k���u���y�U1��>�V���IeYaݠ�o`�y�B����wLG����(&�X��S�6 �Q�fq�FQ'H4h2�>ۃuR)e�8��5�)���i㓽���o�z��	v�M�)Xn�᰿T?�>��&2*�rK�-SR�q �Xz��'V+lK<(��œt�y���7���l�+����Ͱ$��n
���o����Wll3�����]Q2_�b�߻Ñ��%Q����FwM~��r>&�Ӗ��
d}b�1��ꈖ? edi�U���m6��97���A�t���Z"E �r� K�7
��H��f3���C �X�f:�7}n��q��� ��z/�Y7�.��ل!J�񸠐�j5"����1 ��{7S��2��ĩ1�Z�َ�m�*��������w�� �������۱����@,~�'�X^� .ء�Oc��K�YJ�1���4�� ���D����Nag�������p�f3>��l8'Txm3�a-�$���o�Z� ��XU�V�~dv�:F��@s��H���}�TQ$�+�%��K;�B�P`~J�R�M���YD=�
�o�Q��bD�|�=�=�!��G1���Zx?l�#�Ǵ(n7t�x���,N�83	�(|�0�d8��pcKt�b��7��|3���M\z�+Ta���ய3| �#����?�6�F2,/�_�i����|mXJ���^�2�e���j��7���]u�Q��0jcq5�-��o*�fxLNp	�L��?���k�&+�Rz)k9���ӗ���慮$U+vqI����|��i4��� ih6Ø��d����CJ���V|���j�4�h=w}X�>p�h%�x^�A�7Tԭ�>	ۨ�(V�q����%������(�=g����󒜖���7,ɿo����`y�Z�����|�&� ј8��%>P&�Hg߼$A﬊1�u�*3��/EZe����T�ƘV��پ�����>��V+�м�&G�~{�8���Ɏm.)�:���M ��Y�I��8|��m+ �U����LH���������,Z7�U���( c��� ��[�
� /�	�S-�D�%a&��t �����}��L�C$sX..�����yd]�	��(��������^e.>U}�6x���kZ]��{�y}BXL�\g���G�%�xj�*��)���X���퀫k�e��G.P@�X����CI�O�rHxI��3X��c��B�.\��{����Vab�����-���)T����7N��3�8Mt�������52�z���SO�yV������D��a���}8*n����a;������~�>����h�^X�MU���j$�Zl>�1�_!�#����g�V������N��"�e�,*j)�G�%@�z>���1I�P���ŚÔSf�����ZXo�!���t?��	���H���GLO���X �x"���p������_e��!!�R�7�����v�~����������ǜ^��a `�gI�4��bD��7#rfqn	/��W��]�㫊q�p	8=�q�L���o̠�'=�+ւbi�U|��YW���U7J+�?�c�I���!l��U�h��˙�{���*n0'���*�m�¹��n�Z�#��Nn2Kur�MTTcYY��s_n$�B�	�����v�ûA<�M�]�d�;��nΔx�Lכ�^o̱�V7���Ȥ�p��
Ȋ�_2��_�M����t�z�o&
���7+/p�ȝ��f��3�ӱ��oQ�l�>���-xhzF��_�5@��ʱ���P|/"g��ң�;b6'��j��S�Py-WFuB"���4,�N+�:p"�RM�����@��T	��k~���4��o���l�x�g0���مa�g#���nc�k@᱀`bM�;��V%��|c��B{���V���U8�k���٨��nu�V����ǖA�R����'#��-��a��UI��.N]0���N�:��֬!U��r����vx��נs�27��]��S-K솬�y�a'�m~z��o���5��w{`c1�Z'n��@D�T��0��>܌��yh�d[�<[Sp��n�������u����Ŵ�c!�Y?�M�L�<�+�KE)2P��1N#�Uy>9Jp�[3+�ʳ�8�¾\�`    �.e�`4�|hHhk�A����PjYf�dxga��T+��Y���b�p���.�ZC�m�$I��t��͋_M�bKkp��6�Oň�1��]���)���k�@4�b����[���q����<�/�U�Y��' �S��D��oM�6�ږ��'�b�1�2��}v�L��n%c���eթe�����1o�4r�����A�����r1\��1ɍ�72�M�0l��?�6���K3�-�tl�&l��:���dxEPՒ��x���2�)�ޢ��-i�"��=����u ����Y��S�0kbn�j�~�ϲ��9��  �R&�bc�3!h~q��j��@N�VX��#h��0��|��0�ʾe�8μp5��q�*A�Ĉ�&��uB����2_���-��K�_i��0��qq����(�^͂9W?42<�]Ɛ|�)����`���kCvd���M݈"K�ٱr��`�V�Q`~�4��ɢ�7f�m[��X�X���M��3�V�{��AWg����B�������Y�3��� j�m:��M\D-�U���e�V�n9 �@y ���]묛R>��+3��w�N؅���pA���毅�;��X�()��)�d���3a��Ü0։��|7�q���j�[�V Sٟ�>L�U8�I�*�6�k�\�5X�x�+<�
s�E����f�0k����lQjl 7P-bCo�mڽM ��:ؽh�%��V}t��!�N�H�6��Ǣ{�60�&w�Gz��sL�vp(�\����a0k�`_��Q1��|����T�k�H��c�-����i��4H���O�ᮻ��0+��-��薴�B�ȰuФ��ߴ��黧�C�:> ���e_�jQ��T�D���ߖN6�6&�/���0�`�f�M?|�4��sݷd�k�v��J6�
\��o��C2���ew� �-��l��'�00ئ�����c3���X�����W&��9z_A�3��ײ�I9����q^YE"��&�/�	�,)t��n��+n�H�B�E1<����XV��ےDv�0�9j���<u��Lf�iN$~��>�@�]�j��xl��K�O!��W�j��@����^��D�&�ֲ��?�L�Q���><S��a�4v�v��v�>�l�B���!�Yq�u)e��ظ�
7��?�����\"��
�]��ä�%7��k��.�?���U�ĺn������1��u�?�Ǖ��@���<}ڶ�al�z��=������6��5��9"!�Ű�� 6@���[��5��a.&���Q�?���ӵ�~��~�m$̋v>�A�8=o'��B�b��'����zN(>N>|d�V���GC9�U<3����Y8�}��@<S�gc��62�NJ���`ܭ��`��p���it�1���{X��%��
	 ~$��3Y�c&���F"N ��Y|"H�� !�\G�cg�)oIS�d����k�-�気u��L��5�-^fQY��	 �e�����>����M4F��{�u＀������w̶���l�R�������%!聡�K��8��$�BD+]�Y>/�����r&��
[�\+n��Vm��GV^�K�7`Ps��`�0�\��0$���)�	cD USQ }����>P��R�ah�?H]���&���?���<��=�m6����H�Y��V�F��,i�J*1jX�l07ce������
�`G?H�K����јO�YD��a��2�I$���斔$'���x��;&1�6�1í\X�@�6��D�%`S�0��?;���e���bbӌ]�eC�_W�=*�%��;�;��#-�D�Z�lO�-��9�%w�92K���Eg5�n>��!�SO�9��{l%V8�a�X"]�#��|D�a���c�0	6��_ֱ@l����b"��vR�����aa`���n�h�).���!���Z�oh�m�+��s�1m�J��u�JՂU�z=(���	J�"y�q?ͼ����'�`�Q��٨�I\��[�m�V������8���P� ޼������|ڼh���i.����Tc��rh1
�ٗ��d��A3O�v��x �&�qy�V��o����:Yz�X=pj��<�S���,��d�����Y�n���h_@^ob���$���̉ ep�4� �	��D�Y�].<5q�� �\��%k��$�I8�[����Zܺ�#��	䱿����W��C|�T��ҏ�k]��[$�%8��d� �� �͉fGo)F�#��_�-|z���f� �7�f�{��H6Cg�t�B��~�4�w[�ύ��įJG� W�;��~uKi��pa�!�oŖ�X6��hk�Cߧզ�7�,a��n��b�n���yi�AsZ���4O|���v�qrr�f�cw��Oh6����7�cd��?�_�R��c��n���˝4�N ~��ci1����v��\��,i-ve�5������X�|؍�n.)[��z��Z�Rl6P�y!�׸	�f��P�cڹsP��� _�=�얍��	�رC�?�b/��c6��uW��>o�4��k��\}uˤ�a�m�n�]��u�|!�V�¶��öء���Z�044���W�dD�kf�(�m�V}�Z�~Q��n=���	��t���
.����geF�{PL�iX,�� x`�u<���&ar&D��2���(��)
�|}��pԸI���l vdY��o0�e����cY�A@��vZ;�9��F��숿�sE&��闺Ɏ?��8�Ʉtv� �@C��	�iR���4��d!@����%8\�ۣ{�Uآr����"�#c@�~u�����?.�>Vi��S��R3H���p����|�I����nZ�����aH��(�+,:L�����Y������c��!ݦVy�a�!k��Ѷ�>pZ��z���ї5_��? P�>���h���)�Y�xn#]W>_�K�\�7+���6N��ak%�:.Jj�s��D�w˒-'3c`j��I��ڨYʶ�����҃�F�?r����?w�iK �5z�X�.Vg�( A�����Vn���[����9��&��)���9-	(�zڕ��-=_��7��pUJ�����Q��n��ь+;��A���2<��}0<�BJ��k�l
ֳ��R���b���j6��A6m�A���b�h�:�}E�Y&~���t�q�(J�6j��% 3�y��w�������������&��$��s|�c�<+
DJn�@[�����"���L����?<�<�7�-�x�R�YY֍X�b�J�̓^͗��=�W8xʀ�a߄�LƧ�v"��@� w[`$�Qɍ�_�,���_ƃ��L_(�JY���|�4M�e]Nx�P��J��l�nˈ$��z�{�z�iω����G��6�vv��#1B��C'�Pv(�`���o��ޔ��X�_#���n;/_+�1�]�a۝�qT_��H��Ih�Ad_�넕��t�����c�09v�c���m&�(	+�Z�Y;eY��~��c�<��7ZS	�(NrCA��W��{�魇@�n��2v18�B]O@� \��/��h�g�j��IEf7(�B�P0����;��17�I�O�Ѻ|�����=�U+������&���x�[:�7�<k�	�9�;ä'8z�d�^>`���Yݦ��ş�A�@:l��8��ax���¬QpV7Qð"���ɪ-8u7����y~!��kk8�d?�-��E�=�H3+x,�:0z�x�>�ž��d�C�}�iϯg��U�U�x7`Z\����P�⼋i�a;���K��o����Y@��L} ,�y/���j���7�ށ�� 0OiOQ`Wp��n�	r��dw��������q�L�͘l�Y
�M2\f=��$�������ک[mn�l*��y'����/�ڿ�47��a"dGAXc��8c@6�;������i�=�
Η5ߝ&���lݧ�e��rV�r    yL�?����`�ӹ��׹ꌝ��rյ�Y5[M�XC�_f������̖�)��h5��Bޑ??���4�f��o�Uvt�-�:� l��oo	M��J(����G�h��Zw���-����m��f��ė�M��Z�����-g\��K��R�۩�G!u@�`��!��F#$i�~�ߝg����a�>K���r���:`�6�C,�}l��4��c�����j��v�nR��{�9�Ƨ��
��j����'���5��}�B�J@`��ߋ���������;��5W����!<���e�x�8F���ae��`�L?d�ʆmO=�!�����B/��,���/�<��� Nɭ34�ݙ�8Ry�Z��_~M�~ K��1�t�G㕌F�2݂G�F�gP~:HЂW����G�մu�Z ��Y�M�W�P;K�g�����#�][�S$�j���7c��p�c������ǝ៌�-��ԁj��X�����
�{�w��6��4�98�˴Fڂ�{��c~^��-���Q�نVGIgo:�E�@Y�c��%s��`PكzJX���XC9У��4�o�\��{n���z��y�����'��ME��N�5Xf����|���o}���1'Po���1�>�ɛ,�wf��7&dr�s��u��j�#1�w�h�_�ckwv�)L��X��>���a|�m�X�i|��	�a�N�*��[����V];�vy9۾�l�B6���k�<����w��aYBg|�9�po\��e��>�j����Lv��MP�)���T����[MZ~�^߾�Qq��vt�B����l��^DP�I�����nA���ԏ��i$�Lm�e�����Jy@�sEkS��g��l!���5��%ppI�zځ�b���$�{+U�@(�y�;�Α�?VJ��YD(05�U�	)�c�vlh��U�N����l3ֹ;I�Ӿ^��GZ�R�;�,ʀ�g�j����8��t'�@\F����qhO>^���t6��L5w{�M<_�M�궭�>�e�RQl�y�鯯�z34͹�a�f�N��"��,�6��S[��;��M��9��A�	+���5��<S��o��Z�o}i� ,��B�����h�n�x�?�a�N�����o9��Z��ol��q11Jk&nn���<�2�
�	�-��xX_L�	�a�U����cߒ_{�MV�.0����E��7m�3�%��ϝ����G�bC%,��w��r�#Xx�e��� ��&��h%�B��pt�2>$�;SX��X����pl ��0�m�c���(���6���/�V���h�+��Nժ&�F�=q7�|�.�����(�X{i2p>��܆v���U�;�	KZn#�z�N>N�409l���0��*� j^����Zdޒ��Fg'bw�C���_87|��خW��Z}�Ȳ���гn��	Ω�y���3n8����DF�7X��/���� ��.	�%s�ܢ|/t�T���i�sn���|��r��؋]y��r�ы���a>����c�&��|�|1]�f�'������QMES���Bf�ɰ��_<΀*���[ȳ��M`�\�|3wڰ���~|������韼r�����22N���rkO���a���,�8�h�_�4�Nph4'�Wth�w�*~1�w:�3%�:`|�)��X��r�Ǎw6�O��2��1:K�����ň�l��� ��&boA2�cD���(�::P�����<������9�>\�d��-�uv���Z�G��[l����;9d��*T1��2
��M���P���9�u���%m��379�����?w@�OV�It�`�>�{ �m�:�d�����-�����J穞;��<Uh{���*O2>��e��s�}�������hcʰ#G��F�3����H�hk��8u�2R��$�� sp֒=���?�=x6H<��	�����ٚ��H<���-�V��4[�P��,F�^�������#�	���'jaF��7Z�s�W\�4�k���վ�;�����y�\���b�,�}�}��u�?�V14�D[���q.՗�.�4���*��ay1Nx�x���WSj��ݲ F�z�����53����>���&����)�
�4��
+G}FϋE%:$C�����J���+��3�:%8���-�񛩦=�͂ӊ�vu~��T�W��G��H�S��Q�Z���	���:��ۖ��ն���/����uCj��~5w�_�����&�]��m�����E�ȺlAXy���	(�{����Z�~�W�̓����n�m{�ݟEw�ȼ���\|2���$l7�H�������� �ϯ���X
h/��8��hI�7��I�ڲ����DL�/0�vv�g<^�eǆ	gT,y_��B]����t��Q����#P�~.��+í)4EÊt�#� 0�<:,Ѐ���Mob�',��x���1ڀޭ�~��?�����d?� K`m���:6���;�}l�b�}�`d�&*��#�~���~���8��)� �G�紑�FJ��<�O(�r�.��s��jq6gy1۰��O����l6��ߑ'�ij_s:�F���~��7=sڊË��qO^C1Y5��u�\O�a
�:��l0\�� �3�� ;9�Q���	�mm��!Nnv�ɵM���"�+eT���X�#�G����8�Ů~x�n��V�H���L|�K��hr�R���������֩���v��sC��u������3"��M�6��rfZMe��V�N �}ŷ-[Q,�����X���(��� F�{�Gu8��A#8�����g4�}��k8��fy�$�^����n|m>F{��7�Yp{3��޼Fu��g�S������*vΠ�h�e��
�\��ߐ���"�;����
��,�؄�1g���0X���SR~h�ZuM_���X�Dd0����x���d}`p���w� ��~��(l�}(3�����r٭����D@aŭ�p̢s݂�#��޶��5�s�q˩e�D*r����Ot�����3�d��c��6�[b�;^��Sv�~��5B���XH7K�Z�&L��B?�����Rl��銹KK��!�Q)4������bk���EsS`��M�E���d��3�<�¹������ si�F�_�]�c�t�%י83��X	F��r���	7cl��8�U���H�4G
K EiY���U5�]k|��́	�s^��C*�Ra� 
c�{0l�Ƽf��;&.��~ư��V�:}F�+�`�E�aⓩ��p�m�M��͝f�\|�	�{2��䰏�e�sí�wh�5���@I���,r����V���c~��fl�6!f��S����sE�8[��`� 9�˷��� �H�X�X揵t�yp�N����Oð��h�R8 �u��J��Oks?3�щ2E��a�G�;��w*��fB;0° ��f�
��~h�kQw2�m����r���;L21r���G2{�}��-��{͞�ɴ��E��p;��]�RLǭߓj`�N'M�޶ɯ��`�-�p�ı9��b����^��9T��yn�4Kc���ᑌJ;�]�3@!�sԒq,6&���_�`o#�8掠n�nh�V��~��Ίե<�wL���-I�4�Ùb#���U��&7ϳYN[�G�@�O_Țo��:�Iqz�-�AEg/b���b�ؘ4����</:[��\y���f�2vqб�Fvj{��v�y� 'nN�-�����n���RI���UX=���N�-kI �,��0�6�[TA^�m}��z��Ѣd4~�N�{N²��is4�j:�Ct�[VP�_�;7~˶;���vh<���b�����"SP�M����#��]z��rf���xn�KvY�`� (�_?���#���x�N�-te#z)�f�,�}t�ݓ�ڴG���������X�    S��@��^�E.�/�V���ˢ �wZV�=V��ǁ�6��1�=bw�,�\�X��q�/ܜu��V����+*��a:��P$�QW�Rk�t�#���d]'e�#d�-��Y�a�n�V�><�����}��u�6pϷ��1b�jJw#��0���k�s�%���'�-L�.���ū��3�`Dǳ㊧�Jt�!�u*�'N�f���AIvT:�uj�����P�;&�[ԁ����d�=���8�ױw�2R���0`�dxtf݉�WNF�r���1���^��c���Q��N�ٱ�x��r��Y���ز
3��~�1q��Q��N �=Fn��q�����Y:�E�rƗ�ؘ�1����6>��2V��/�	{y��H ]����|��!l ]3�`;�9��hB����x��ܠיN<4>��"�~���~�~��M���;��y6�$b-Ql�8D��M_soV*���;9�Uʦׄ�}�B}��P|&�����1���r��2�(
+�y|��
f���X:��W��4����Ѝ�X�p���NK2���N�bC�E�$�E��D�-�9~�l��)�iF,�G��x�x6��)`E����v���3ʜԯ�wr���d����f�x����p�/�ra����XDm�ϝ�e���4�pޅ��Bǵ�ٖ����f��wgw���3��[�5ܠ��:�=����A���2���L����Vg
t;������5ׁ�5;:*�&Wj$ B8�h�������s�^k-�0s�Z:�,�)<m�Va%����<)cq����jg\Zd������t�6�~��8\��"�|Ρt_�8��]��+��Ժ�Z+:Y�騡W�;tЖ_R�0�w��/�"M�Q�.��x�e�|��Rz(r`H֋�����m�����JN�07f��#��v���!PP�(�� �,�J�/e+�Y���[���x��6FѾ}U����
�SÐp�6�b��;9,7�0��#�����,"�-�� �#�FW���9[��*���;]�篼Jl$g���[������Dv�9��U�$W,G2�*�s�n�+#8����Vc�n�ր^Y�����O�-"c��\�{��d���(ɩQ����?d�ƣ����v!�5�(�4�Na������7ЙȰ_t�))�na^�V���rR��u��_vlo�y>�MD�{�&(���F᠞�g!�O,�B��?�_N�bW��MCl�r�_�Ͱ��s�H7o�HL�
�Q���(ky�!@�.�s96*W�'xy���d�,X6�p��K�H���'n����p��[��<�ǏF�?�df��`[�h����e������=�4Z�i^�ޓ2�E�(��%P�Ї��s�U+�O�|����!�e��0lu0l�4Dd�T�ey�#Zwj�,ڍێ�qKh��P�=���\+�L�Y�0sã�5��v�N��噭c��Og���(�a��o��f��HgƔ�Ѽ��;O�������/�s�zOq�hlU���u�Uu,�!��m�D�z�;��CǐR ��G,b��X\�;eh��n�G�8��<��Mn�3h��8n�����N���YX�h;� [0�=(����-�8����8X�����Z��-?����=� �o��) �.�����K��A��ǸX����h˺�i"<S����k3��Fޣ�� (`�j9�/[�g��k��͟d5̴�����o�.���9���x�;(0�9���x�Ú)��+��@�A�p�$=	��$��Y�"���U�7(r)��)x=��7�2O0w�"�c�'r��P�i�����,���)�7Ɉ�-F�ٻy�u���	0w4c�
Ά���8Y�n������&�{��ꒋ:����4)h9y�t<FZAY���hrO��:fn�C��>0EZ�&�m[o�@ �ak���F$���}��p�Nhq�YM;��s�Ǩ�*S#�cl{:��m��G��r�� T �Hj���)#ْ[<F��c��n���;������mx�IT��ZTDZzl
��d�������ۻa�~�S S&"�V�Y���OT�<h�} ��?����[az;d<i׃��\���HerD˖���U�O�����e�Y	�JV
�~�b}�Y��>�Up$ƱyH���Ģ�������R:��o�k��Ո��I��Y�L�t>����'�8v�$}�� ��
�}>�%E��lg^�{�v���أ�a'6W�g���'�xF�)�& ��T��q_����Ѐ/݉4z'��������P�ʍ��L�f��i�\�"2k�M&oG��v����Ⱥ��	!�V�X��@L�h�g])��n�7h�߹��֓l����A�������<�Y8!����˲hVp�a|ΧsԵd�NٵT�I�+ߩ~���BC�ύ'xH�>���F$�uAʹ�׈{eEϴ�}��ͷ�!�"����T3��,��
��V�&[`��8�
3��=��2��s+�ca6��ǘ�G�_�I`�x�.��̷��ߩ-�}����1x̱�ټ��;�A��!$��e���g�X����Zb������	x����.��o�%_���D�fGьa��i�p;�6�~����"~%Ta���w��i��U�����+_}�gˊS�_i	��IzqF{���Z�sa���0�̾��iI��9��y�p٨`1���y0.�-���&�q�ޭ�	�~�����Be�UV�:^��'&�E�'��\���1&��wבY�ibM�`n��7��7[�*�aeK��k��;�ʳP<x��f�e��i3y<(J�.�59�{���py8T'�X����:>k)Rw�fY�0�r�k�����Z��n
i<�4d	�%ӿ�-p��>� ��ī�c���Z,/�C�n���Q0]�y�����8a�Vv�t���j�3UPyd(Tuڛ�S
�7y���8�������P�(`T�H�%�؆;�/��|���i�P�a�AE��Dc7G�x���)��u���������W/a���5'�yW�i��F��	�~n3�#�m����Y�ZY3ٴ��避v]��)��	�q���r���,��K^�AZ�{s���<�X�x���Q6Y��O�޽����=n�3�d]�GRx�]z�E�֛6��'�s(ˑ��Ny���>�GeG��< 5�~/� pn��h�����c3K8���������9����JjPۭ![N�mw����ӱ������7��ŉ#nXV���Sr����~��y�0N���X]��"�{����C�.��\�s��<�/�-�d��Vέk��9���1B���7��0�u�h=�*ZhU��"�w�Ӱ�#%Ce-5�|���lx���(��j�'��pB�Ca7o�,䍧;~Z��YH�q8B��zW'�)Z�ɠ��~<#�qG��i. "���`��K����9��4�[�!�y��4���(�1���*n������T�yqѣ�X��3�v��O�F��r���vw��!��_������>��4װs�3Ls�"����c�D��z�����{�@�~T�9�N�73{F�(�&��л�	�h�����y�lS��`S�[~t�kP�_��x��}�}����
pn�@��B�!��cÁ7��zO�W�e���i�	���K�;߬�L��8-�wR�}�t�!>����V���΍��40ex�;�`�ϟ�|S�F���:\��;�	�[���:H:�;H�WЍϣN��:,�!�k�:�'�z~�Q��W�2�
�L~�߉|�]و	��9Pu�a>z3��V����?5��ؽ����|\ΧǴ�`�Z��g<1��<���×w��4��D�ǌ��ޖ����F3��pNߟ)u���jZY��`�,2?V-��p$���t��q�wɁ��}?�+�2F�p�܅�����Oқ���??���y�:A��j���[�0 �ٜ�wWLU�=�N�p�kz��    �x�Po<puE'��=�{��S�f�1�f2��%�S�=]`�Z9����,��G^�5߯��bzn:9Z-�L�z�zm�RGH��ꋬ<-�J�?x9���p9H�=j�(vÇ|�8�����ʮ*����C-߷�1���'�ܹR@�2k�����$ �{�v��dg:N09�|4ۈ<�G���)�L�=^���� PE�K�]�Vz�{3�fkYu��	Q���	�lD��Äe�{h���:�n��p{lAX}��t�W��Y�Ǯ�t�Ӻ$ܤ�e��1���NlD��o3��kZ�؜���[�=R���٫k�����aO}�
��c}6���*����V`���8�"z�m��]���S9�-�{&2��y����8+�b�0[�bm��6�x�����n~�n�>y信��	=���ތ8�n5�D�b[�J�Q;�NU�S���˹2��-#vxJ¯��d���C�P�=�4<��c�3�풹R��U�B`���]h���B��ɯ��=UERw���\%���3�����΅H��<�R����>�r�����7�
�M�<����Mި���:8˧�	�[B�\=LO��DAȟ�4k.��Fv�4[On_f[��)&�d�y(v�!��TGC�����d��Gݏ{�ܼ�� ����:WcR��N�����&�e���8n�o"5"�9�����P�q8�0��`vcȅ��>�{tf���:'���;yZ�fN[$��>�����┰��'.z&6�}�dj��#{CED-�n���8�:������l,��>�g�,3�%�Q熽�E�>C�T�f���1]��*$7|c����f(��d�^1]V1��$��V\,��2�T���'�׎gA<d�v,�0�^���j���T;Y��zT���Ag�:�r�؋݊GD�ŶV��<���k���Z��4���@����CĶ}+�$ #;���l�_����@N�� ����i0���q��Y���i���0nC����'X+q;VLcx�i ���������m�S����Ɔ{<B�`�fc3pM==ѓ.p���z�d��S�,�h�����r��͓�Yw��t<���#�< 6���
এ�L�ؑ��Nxrԫ}�����/n�7�����ݵ�/	7S�_g����'�~�DX�;�6������,Y�G�O�e�hѲ��2�%�P,S���;��Nm����h�|}{K�ݠds��p,���{o��-۠�׶�7����U��p$��\�9,AT:^�2y�w� I�=D2��OQ����~��[3����w���V�D<�����I��o������I �t��&�X��5���⋧�v��{���G:4�#1��D���M|�O%'� ��3/�=��Ϡ����Q���H�cdC����xj�IC��״_��<���y=��}�l/�Rⳛ	c�ܶ��ǁ�Gxv�6���-WZ�NroNX�<x��EО�[�{�矹&���;�o�P�jC�,3d)�=K>y>`�CQ��V]�cy�E6(�Y��cD�8 �5�u�/E��#䢬�w�A�!��U ��rz��� S�N�FX���䉯�,��b��e炱�~O}�}�������_���N
s��4ȱ���4��J?;2���������9v�R���n�z#��s��$8�MEk'���|����~C��c�h�g܈jRÇ�W�ۘ�D�w|�cB֐�`�F���'�cu�=��sȟ�Ǵ`�Z���P��)G�9W�92����'sj��.�����~M!�TP��c9�m�|o'Ѵ���k�=X�YqI41�Hg9��sX9�? ��h�s�GWG��?�QqY#�S��� �y���x���VsZ�x�X3�N� ^Zf6�����{����[˩z����ͽٶ{��=��ot��9�ϑ�:�Ɉ ��o׳e4L����	?��l���} >K�=���ٸ�;��zc(��UbF�E�9E�Cg=��u���}��������#�����-��[B�A�란�?8���w
��>{��Ln<7�dker�����msg�g���3z�M�B�'��N��i>�	#�<�l�
�3)��&''����3���{s[U�e�U��$@-|8CF�����]�gZp<4��_�dt��F�YQ����|�����vGKwu&���z��y`�ǣYl��E�LO9���w*�aUl�77�i^�6�e��z�u����r�f�[���sU��`�/߹�)�oz�s��-zƽ�=�R����9|�;^�z�;��j�4L�y�K2��a0w��� ��=�z���>�@���͗ϧ��|v�3������V�E�@�f:EB��T�����>�|��,��(��lC�	���b��x80��d�8������[���d������=�Py~p��agR������v��i��p�2}�˻<cԬ7����=s�81�Һ�)�3����{�t1�o9��Q�g���L�X� (es�=+�<��f��E�M�Z4�|;zc�~gm�m7��]�f)�l�Λ��;Z-�A��㝳^�gE�FS��m����D��k��:��6�x�Q!O&�U(�2ٔ��e�`;�Ξy���:`���m��� ɒexF\���x���;��>��d��!���;E���-�`��'�U�y�`}u�e,�c�q�U�Tm���2˄�w2�tx�[#�,^���������L?��������	��:��c�����a&�����q�'�Ƕ»��y�h�i@�z8�n#��������c[:�ǩ���-I:��&9�S�x$����Z�KIX�-���aD���tpc����S�8���L!4ݡ�Ã�=�BTPL��՛�9FW=�%'�����v��܊�W�!v�΅����Ch��^�rP�C������QU<��������<����F3j��Ï�*��y^�h�{~�����|Fw:�N����ղ�������0��s<���9��]��Q�������;P�s���\����a ?�d��	nX���9��>�[��#�::?���vW0�!�a{f��O"9.����xY�P=t� �h���s���a}w�ntǓP��0�x���ǿ���UK�Ί�Zl��h���l�U�J�"QG�۝o>ټ�H���ݓl�ns0�Si���V��*�#���w�Ə����(CS ˉ�]l�)��y'�%�R�p�+�;��s�V�ax���n�i��c���0�в_/�h�������D�:�=yD�M���I���JFu;��#ag40h�]���!p/O��NMq�'-�q���p�ޚ۷�E��-;,���[;ht�;�O�CR{�%�LG��^��ݝ=�
�A���}"@��im�M�����l|@m���A�����K=�t�7��u�eݱ|�*oy������ёb�#� Y}���tp<��5�n�
9[j^�M�Q0�	Ja�e^XO�04�d�{$rw4�5���16�!'���������(�@�c�p� �C���E�$cm{�M8ow�{�s��sg�n�1��\k�4�� 68�6��n$c��V��g�.ς�,�}��7Mw� )�E�vK��0�	q�3�����2#��@z��C&7�L7��*��'��0��\��o�W?�t��N��
>lvq0���T��Lz���"��%�� ����m)���{41@��%Q/���k����x�xarbUa^8���%��eO��(8�5Ő}�N��g[1���Z���}^A��y ��<sd�-1�Th&aAp[4���q�Rs�����qI%a*��
�z���lF[8^����~��P��e�Z�n�1��;��<oo�����)��H���gtx�<�+?<�V*3�U��<���|�wFԻj��e���<�lĪ�Ѡ�`g�&<�O6x��v['��|Nb�ٲ�i�6Ve��6`�AL�O#j��4AWae��vs�FA&��+��rEA��y*�\g>��m*��4A�_{���,����Mk���q<�;��7    ����ԍ��s�L��8��I	o�d��Q�����6Q?aY3����+��,�%:O�F�(����i}�*����o�̈Uv៉�6�WCi�;6�T:n~Ϲ���%�8k�{F|�jT�
�x��*I�aO���5O���n�ҹ���{!�!�0�Zc�P��Iz�	;���/5R$�Yޔc��,�B�>��P�H^2�XËC��NA���9	����:�7�q}��+���Mپ��2j�SK�п��r�~�&C!vhA�4���Bp@�ڎ�P��H�EmQ��N~_��)��:��݌#غ��AYi�7Ͽ�-{����F����;�T)�2	�Ē��g�(U��ZK���<U��4���o��ڴ��r����Cq�P�|��n�^�y{ڳP��+9i" �%Q��9m��"�^x��Z`���+9B�,��pU_U�v��a@>o{��t�4`�k��-�ą�]uI�|�VӚ
�����[������Ȓ-S1m٘e&�~���+M�%��z�D��òa�0������B�t��+���i��g����B�s���C@��P��)�[B�Q2jXz�b����'?Ƽ���`�AP���ї�y���^��SlrX�P�7:�L5��j�TS餈%ؠB�z�2={)�֐<��p^3oĂ��sPG���t�����&�	f�H&Ŀ�~ߒ��ԋ�m���	�a���h�o��Rr�!�M�h�<��w�q�L��PpJKU�� g}%���w�@9������i3/$+���g�����+Zr�P� ��6+���dp�%��%�5����#9W �1/>�C�-�l��ҵ��Hl�p��Xi( ��qO�u���^v0�������@�Jg�`�y3��r�
rD?�'�| �P�G�&��ٖ
�98P=���R%�r�e��B&��`g��B���<;�QX*��{"?b�����c6��8�"�`L�W�A����nɠ��v�F����������Ժ�4Eȏs�u{�ܷ߷|��ꥨGe�ΒY.>�)A&����@�'O��)������2I���@���l�-�5�M�E2���I����c�9ds���Sk��/���كAA�'���&��$ |�;\�T���������g�v=��{�i�N:���ք.g��q'�>�>#�q&�e�=��՜<-_w3\L{�]���ӥJ�9���V�H�J���9�V�F`;�Fow�&,��+36����2<�r�)�Ce Q�
�:��|����Hb�W�U�k��\ⵐ��;��Â�Y��X��qAC��rgp�	��N�^�A&SQ-x�yڌ���V%h��r딷W�`g�k��9�)ߢ���G$�	N~J�+1����p}�ї�'��y��!j��m��q�N�����ib�>��/�]z�9. �Ђ�ڭ��"k��@l�!�2���2$;�� ])�!���F9��~L��Sj�i���4���$CDдW�К5�=izj�(�[�����`���f���ꪨ�K7%(�*���G��b{��yO)0��*"{�԰��[�jQA�q�a�A��<χS��>�L}�jz�{Q����N ����lA8eL7d�Mm��@V>?q�j��٘�\C^�kh�S�?鑻7r�ӓ2�(Qn d�r��:o�3���e��W��*���L�W�)���o���̻?��=Cnm�����?�޶tDG�/�Tyy^��ϸ���!����律ֱ� 2��� ::�IH� �bi.T%�0�p��=�Ϳȇ�7ܨu�{L=�T��-���Lꀙ�n�`�����wJ厝Q��	��(��ae�u���2�<��x����ci�'��{�9�b#�ԙbDw}smv�s��Q�	_���;;OJ�ҋ5�"��1Ӌ�3�7���Ef��v��}��<��	\%� **<�9-���XY���O���Lc���H�?����U�%?�1�hӜ22����:�u5���4���U���9�{���n�ɻ	-�o����J@Nh;zz�>���Ln�)����xJ��8��ț'�T"�ȟ#'<1[	<+EWW�"���|���*��*��dF��)"� ����\ʊXU�� �D;֫�
�֎�G��K*G��!~V�Ɛy|��i��vS�RΓ��-;_<U�`�R�� E�[�,�P15L^��ٹ���8���7�ܦ۵=h='��mzP�?3���c���G<��#���*R��i0]���$�c��HZ&�3�i���M~��~ϳ�d0e�,�N����*��K}Ec8�rA����V`c��sN�i��=딧�җ ���,�c�y��!�mן� ��d0�D������A�)甶�-є)(�^�e��в�YZ1�AY�ю�9�6���}b&٧�Y��P��/a�cS��\Ss���X=��
��I-�� �9u?\kj�m6�ʹ���y��ԯ�@�|�B��-ל���e��ڭ���Xgw�6� ��k�C ���@��v�w��P"A��T�������H��Zw��Tjy��E�d<�`�e���5f��(G%uVz�>��|�;�+��DEI�2�J�v�U.0����9�ً˞���*�t���p�y)�XG�|�w�PED��a2����E>56��r�~�
�jߙ]���C��LJ�:�ͬ��5E���#J{�H�/L��C'B�=%�A�+�ڱ�9�%��Lk�}H^��MzjS��*q\�SX��(��(��o�d͓�u���o��������;DX��G��&TC�^K�biup��n�w*v+��4L����z�v ����ܴB�S$�����0�$��^�k�,R�2#f��+��G?�wv���l�O���e��tu�[^t��d�y/�*�äwk�V77�Q6�4�r@N�3���Ё��_��p�b�^-�:�2�o,&��Ldܖ��c�=Q��5#ԩ�i�ݸ�f���	�5KJ��J�I׋Y��Z&cA4w{�)�C��əȱɣSx}\X¥W�Y��e�G���o&��O:���`)#n?e�DG�,I9��60[��.��Aޢ(�������bpM�o�q�-YW+�<pB32ma��� ��z?��K7�Տ6��������ט��ƣ����u:�|ۥ#�b*����"��%V"��"��$�TӘ��*���$Y���-�5cLj*I_6��Y��4%;���J*��ɻ5��J��}t�����T��Q�1��-3��E����T�mt*��w�h�k%���o. ���-;�;u�̚"	/�9o��X(�x�o�y�7�D't��%�%;��1LO�����g�$�1� n��*��Q?r�Ͷ�ZR�^���Q�h����������㜋yn��
h羽`�-׼wz��a���1�T���f�{���=�w�����y�=��+���W�Y��Y��� w�������CnQ��c��v�9VP�J35O�S��S����3^�(���yF��C	����Q)�[��OdUm��yko	k�]ii�VS�X+p�$9����Xԁ�#q�_pW4彆>x�s��7$�Tav&U&X���\!n�g��hG���`9 k����=&�?e��M�15-p�k�y�P�t�	���m�y��[!�s�ja��1^?S_�oJ�N\�d��P����x���q�r�Ж��2�K�Hn��O0�}�ߗ��}�.=�����{|Z:�	�����2t��|���TP^�Y8�t6�oY���Nu�C����u)�vc��Ì0q+5��=]��Kx��m��#V����5+Av˫�Vb��-j6M�gF�(a*�v�D#y�'7�9�Nu��8g��k��\��.�Q� ��wN��x�>X�>ʪ�V_��jM��1v�e��iJ朥�lf-=����N���`>�C��5�i�:�贓����:X�		�3J�b��� �˲(�&��7�sB�J봚�%}��Jel�쥤����|) �P��k$�� ¦��s��S�l�ϙ�05�ă󡴕�c���a�h
�Ʌ;�r�3�.5����7�'�}�iZ��j�Y2�	vE�W��4>i�.���;UN�    Z�&_���H�S��}��(FXX ��3b|��w'�ͳi�Es������\U����;��l��N���(<s��m��C�b)I�T��&*i��9yn�r(-��	�tʟ����g��\5t���4O�L+��9L��,�D��%��ȓY�����J��<g��<d�+�+�9Bu<�*�CK^�A*c�ie�Z�9| ��F���=�Gr��]��B��_>�WRֶ�tGۿ%MXo����l�c�R�b�</H�y���!2�cP$���}��%s/���we(�Sݥ��[.S9i<�WR9�\�v�����^.?Z�)�n鉜���::�������8���ؗns4@S��)��Q�%،�g���~~^R�K��i܆r:wg�2ڀt�u*�7JlX�����Yn{�n@�ezAw.K��ܿ��ƞ^�-o$r��S����S���V|���d�͖߅���Pڙ���ǥR�����F���M�u�YXI�n������4��ַ��o��v���֔D��$	m�y��A�L˞g	Xt��h\�����mɲtOU9T�����W��� ��S�5�;��D�v����X�$��)?+�<a%���%��X��T���'��Ai��rm��-}�5�EY�B�)7/y�}hQ���[��[U��?�f�><e�i����l[
��`%y�!�O;���]-(��[N~�Ĵ�"��R��Ha��޽���?�m3u+cD��)?ʏ���z1@��v��'SX�V9�ga6{�۝�w�nF��./`J}SK8�bR��S���<�3yfi�w��T�;qv��ʢ�
��Ip9{�����@�\���
י<�E��(�%�� *J�yN�{���k ��Q�O4g3ʃQ8���)#�4*j��"!��&7q�JwR����?땂G�5{-��u��4�r' L����:���IQ�r���z���#�js�R�n����6_l9��,�D�����z/�vȩe^��^.�]��,�h�S�\L^ﹼ~�� �zj�yi��[!�@��ΎQ�ŧNiQMer�s�#�V|�n�'�n>�n#�2�7p�A�(}o;d�C2�|=�G�fI����ot�hݵ,J{�n#� L�3�~���Fi�ϕ���˒3ʉ%��4�uAcT��k��M��OI��g\�p�o}i?vv�b ]���	���'�$o�R��E��]���D|h��6��$DOG�����Χ�n��;մ�e���?ӳSay�����g�c���n�N"MO��f���-&���(���d�j�U9��M��+]z�":$�&f�%>Mh��ױ_�&yBkqNL;s�==��� �NU�иA��g�s�9�i)�Q����ߘ�ߟE��m�'���"Ǫ`J7
����iFtZ��]$*#S���ք�KJ"&L�t@�C���i���d��gfz�?���Tu^}7�4J� Hv��wN�	�9�	���w3�1�y?/��`��M5a���7c������<Y�fS�����a�ql�)�	�n<�J`�l�\��Y���K�������/��/�*0� �0�X�B�����!D8{�<���fL��%E�`��+ijd%���s�����Ĩ�k�H�����aRH4�S��K��~������JK��QKݐ�J��5D�ҮҀ��:]ŷLn��Z0z�g	��Ǐ|�~$<��I㳈�%TW�$��l�U]3�a'��,ro�/Hɟ��Q�J�](����C����L ��≅�^[�>����ӳ����?���C�})ݻ�����'�^應$[Ӡ�,@�:x�O�dN�0j!��,��������<�k*ⵦ)8S�ޅ�8Sx���1{]��ˎ��ey~�p���1O4��Oܚh�ĆM7m��Gy�d ɺ��Mi�s��x�ݵ��Q��3?��~�j#?�6����C�_Iڳ���p�ψ%Pm�@5Mo�0��\���,�o� 7������X�J�����T/6�1��2�ac�;�<�=�b��.��u���p�"3��rN�9<����ڒY��B�n��RZ�nO��2�I_9��߿4���W�l���.�;���?u���8�n䛿�|�\���@W����Ju�X���9T�+-G�.-�f8�{�\5C)�y?�����%[�9���=f�kH=t"o>oi��b�����0`�T�IL�ۺ�Yj�2L)a�D��/"v�⹽=�J�Ƨ8ת$�

��}ݏ�;���	���)�w���&&w�"�_�\R����3��Z:���"����%�fh��=�����s�w��� �X��U�~���!�.uS��W#���ڰ��^��.�����@p~`}�դ�9M�!vR�娘nO���T�8<��40�R��
bxz���Fw��+�ƫ��]+�������S���˹%e�q�J� �o���f�F�y|�܄��y���VT0{��`_�N�re�KI�Dw>���b��N+���-ܔ����S�F\�����Nγ�'x��ul:�S)ri,ǔx��u���~���j╷C�2��W��(;����"H+L(Y>x5(�#��Őn*��Z+���1Tҙ,����|�F�=	7wÄP��L53m]։���1����\�Lv{b��'`��d��}}��fp�z���	y���f�����<ߥ�;��D���DE[�~��K>n����M�����`	f���vr�Z��F�hR�XS�Nd�S0o����T��Eşttb��˞�� ��������bKr�J=!R8�k-|�j��d���k���|���(���@S��9�@ �ކ�~���Q��[&�>���m�v�yMb�������gI�~{	�Zjs,8&ؤu:�B,��/�E&��<:��iD�?߷�����N?�o�^�d>Ozݗ'��r���8�`����}�9w|�� q��v	*PL"������m������7��%�����Tt%y2�kh���yK�pW���{Y�ϕN��L�L3���NgAFs�j��JpxeB��4������H��KÍ5�'����q@
��;� �R�~�I!�i�n;��l󳢙K�%�fU$2#�����1 !w����5��$�\��OЗZ�:�}�o�,�6]�|�-�me������(N%����$�����^8��b=���ʦK����>,��fFQ��T�tO
��(=�Ai��>�uA*L,��c��T��" ���3K��	+��yGs'}�{&٧Fys�� �^�a�?ϟO�SM��i�LJ#��$��ĵޑ��1�g.f���DW�Ʋ��#l�6������o�Cf��Y���@03	�_����w��1��?��$,�teWGv�V7�,�Ok�ԝ���ܕK:��LY3����f�s�\@����bA��+���*h+�h�eS"g>|���-ݠ3�1�a��~X�|B�Dz���O�9!����ӡ��Vힰ�+��
��By��RMAX%N`h�	���y<�[�U�����>�<�}.}u��D���&��q*�£�5W�T�k�o���2������yGRݰ,
N�06�>�	أ�qNt��(\���^�ԫ��9�g�%��t0�>_���� �/m��X�a��`��|%��k
�܊iލJY�q�X���#ƙ�7_v���i���/@��B�8��^�0��Xd�Ne���F�-�~�f7�c,�'���2���(`�F���K:�Z%�)��>�/�,ۼ3guW7I�j[�\���\&S� �T_�C|��([���9LW){�d#n�k�x��2�OBa/��}�����<��(!�F�}7G�9D��bٹ��$/����0���\+�)�l͐�u��t�м嬆���K�Fn�_�� F���
B/B`^����J�%���	D�g�ܕ��<� b`9�@%��ڛ-7�sih�%�Z._��\�yF�E ��|�d��8��J�3U���xI�`��gb?D��~c������R���f�)ڐ_�Y�X-�t����Ge�{r����f�#�uu�$#���niK�:�4�w�5'�    �/Z"�~���ʃ����.�*�Hl��M��65�;����1�3h���A��R�bak�ե��g�m*X���-�-��\}�_{n8�O�aÇ'��)�����*�wWC�w>�:?��c?���{a��]��		���U�\�OC���2����ɉ2�<��0{#h����c�-Iɞ\~qYkj�mh�0':��6�͍�%��j2qw* ֥�xH:慳��em9��R�3dɭm<���ɮ%�t��ȗH�?��)�KA�xi����2�L����Ao�����3�o��d����:��.���[%�`��ڂ��N.%«	�S�
�[��kN��%k7v~%����ڬ�u"�4n(�,A<aZ�v�i|-q�z+=����v VqZ��c�9]7�3���Q�'w������� R���-��I,�>>��o.�B$�	W��K˵��&�wԪ/�j��^N�s�FU���:��� �}hf��9=[��$v��@=Or��9���@�h.!O��R���wi�ɘ�M	��&kV��ΰ�K�f*1��ϯƟ���,�f"�:N�Y@H�m�^M`��@g��ZN�z����/���uc�6��Yy�|c[��ăH-8�+���C4%v��;u%�X!�,4X���~9��:.Ñ*Ρ`��R�)ʹ/`��g`J���"��(m�t�rբ.��1�c���kt�K4�y�
^��;����������<�	19��خ}x�g���v$D�w���S	ѧ�A۾ˠ��f�Z�8M|7Mǽ*ݷ��e
s��y%ۓ�
)b)�`!:�,����]��>��t����Z����U�F��.}Q/�3�I�9��1��vé�r�1LU���t�SlY6��K�׋��3p�n1}�)g;9ώo���	�3z�I�ou~�	��0'��QHb�������H(	|��p���s/��t��{�	�:),H_R�	�^gZ�s":���r����2 /�s6�ݽ��M]	�{C_.�{�S�K��s�p��L�Ƴ~`Ư�E�����)��ԍ��yi�N2�I ��m�_�h�t�s�3c	���/{	ߘy绾<<d���k��L�5{����%�}v!?w�$�c�R�m�2�(�3����q!��,\OgurZ�,�At���#fm_(9$˃� q���e�LI6݊S�����20�H�{�	�iL( �RP�k:����|q Rr"swl蟷o�P���*g�w�D�m;sV����_5��y�fRVM�	���IT���3M�BL��[����`�3yk�ƇbS�>)��	섺<���i�Q_6�@�m���r�������F#)"�)	��)a{bB�=w��Jz,�Вu��g.͐)���%_��_�ϋ{J
WjVS�+��5��u� ��R ��l��';+͎B#NT��ͼӔ]3�ulN�����fXi0��);JW����%��rD���68��֤��O�S��?�0���:$�E����#�v�l��k^?�Q�p9�������j����4XT"�q��pq��� ˝WJ?��;t�䭴������#�D�?���f�NZ^)i�i;:4�%2�۞�׌,A��r �����F����`��������"��"��j�W��gu*�_)?eІ��c��J���9r�er�VJ���I*&��[V�F,��N�{Bh�6wxӣ�,�yu|2��Z����hc�]g��1���tJ�	5�C�<4��R���| K\
��'�ujɦ���ݥ��p�)��i�s?���t�������U3O�i)�i�iS���r�#��ƈ./&UkP����ƛ��M��4�WB8�F��Ss�	4 � ��|���+�du��5@��r\�����l�
�Z	f�|I��8|���Χ�#���oOg��tL����	�i���k΋�.�z0U��P��j�+,C��Xx���4��1:"A��X� kH�`=�.3d�qdwh Vc��Y"���H��\(��r�&d	~�7[�*���Ez�WN�FH��T�����J=�㛾�\ēR��08���=/<eI*�I(3�Ŝ��A<��]�)��j�V�p��	�C���f>��/v+������`��/]SN�[���a��3F"�"��+�N=r�LFi�ix;��Z���=�NY���C�U6���9n�}��$ײr��LPѬ�b�t6s�|4�I �O)9�9�OӖ�|�,۶a>��HU~��v~�4��_:7�58��|����9����`������[��p�aٴ칰�P��J����L=���SU�(��0\[��7��P��K�;A4n��u�;��}��O�� �>RM�5��mm����j�a����p���G�Ė�r��
y�9F$^���4���. �r4��M�����z˹�o�_����Kk4��?�|r��80�y�?H�B�1e�I���C~��w�4��ާ�f��c]q�% ���G�`5?�*[�(�F�;6\�%g�v��pF-����Ð�k;�9���p$m����KU-*/s�M���6q���pio׳\#SZ/� ���/+y�)��tO����'�J@k1r �F�����N/sY�0�H��
4���QK���}��_�j���	�
��D���лo$i�%ro����F�2[����R����?To֧���uˣ�_��#4���+m6*�r�IlmM��Ǩ�I��ob�v%s�DMj��y���|���i(P�)�$Y3�Jy�GblNQ��6��$^RR��y�0E=�.ԜQ�՘+���l55�4My�z+����aN4m�u&�f�{�4T\�V*��Lh@����Gҹ滸}9s�W�+���� +?��h����r)	�����OQ�sc5�b�Jy@x�iC����[|1�HUN]cSw��8�t}m*1;��I؛�<���m�Fi�q�l1~J��ջ�G��{�ͤT/*I�+j�iQ��0������+�N{��R�mVd���0y`�8�4�gj��A�(C���LP����_:Ԕ����<��?<��(iܶ�����H�jѭ&�&�=WJ�(�0Z��Q���e�D�++����S%%SPz4!��?Ch���$�Sb.����K53��y:
�}�[�������>�vc���wqO��=�����m��0_�2��C%W�m������fu�<���(���Y�O�(Wr�`B���Uc!�2q�'�&�ʶrE_NA����j�BꝷZ����\��.�T��+��C�����r$SmKqeD��$�^IK�D��?X#��R�>��'�f"����g�Gέ{g�B�b(=�p�� �@`���AgwÎINz�u�b��'��;�-5�aEJб�5|��ɧ3?XO+�D�q��D����V.1h�)�GN_r�AK:�A�{�1�֗�(VK�I<�p�R��)�S���1�NNm,�0�^_�h��}M�熐��.�v;Ofg�SS~||f��(��R�'A/W�ֺ�Ȃ6u$e��+���=�-���w���9�˒�Lކ����;3�ԅ9�)R�E�H��#��#�C�����KB���1�?s?�pҭC��M�٩K����D�� ��VN���7�L2
����f�V�X�sF�9�'��y兕����&��������ҩKm8=_j_�D2��|
]>l�Eu�-m��C��/9�l���j��j<�O��y�оPx�FE>�V��:t��MC��T���SR�L]�:!Vd�Cr���2��	��is~�1�)�ú��I��4���M�2��<�6��������J0�>�j>�N��f��`r ���9����f@��j��D����%�Y�ļS��:��^n䧞����q҄����e��j&i�����5C=�1S��.�#� �q�ڍ�6��9�?<�|�t�i�+o��":O��>��zl'i��06�q�8��0���Lj�T�-����,����؍ns��,�ܤ���N_�QڮB��MAA��ᰥ~�58�_����5�Ξߞ�d�w'��d�S�N�a�%p��ia�n�����    9�8]�I�K~��o�4��<D��i�]j''@�k���<�S�W��/�h���e�I�z��b��h��N@
{Ѯ_����J���[j�˒wq�!`�*�����lL���'G���_�v�+��iZ7sΎ�ђ�8�'����l����i"
B�ʚ���\�G�;0-i�7&��*ײ�8`�!r����\�3o�@��rC�|{S�|j��scz�]$O��u��A�� ���\��5�?����v�s����Oi샵ޏ��7�%�&ϗ�T+e_�)LOںȞ�綷jC�e�~��� �Zn$�B��i��/}�ڀ�B<a.�r$��G�SP�[�3U�ӹ��. ��[1KJk*�4��:R��������Sㆤ�e���f!���8�)P��f�>1�oS��!�:�Ǭ�����%:��H��&2�����)f�I .M��Z�����r��(9�� 'I�T��_<�P�~n��*�Jz��\��)��If���0Yz�a��B�&m�Y�5epNV>�QA�o�\@��PHB���$m�91R� �Kl�<��}>�Q��� ��8�Wj�+O� �����4�L�	2�A�G����N���"|�IFѽ��fm�D��C�,}>��W��ϥb�e�p@���sW(����1J=!Kk��X�%���ŝ7��92�K�����/۝r�x+*B�Y��E��v�]���5��c5���ɣ�̩s��Ҍ8ҩ$l]���ꎆ�V�8)2��DgSA$��M���u�ż��C�]׎�V�Z1
�@��4R�{����&��L�<�ڀ$o�����w���БbP�����'�\�F�Fa�U�ʅ/=\�.�(��՗6�yI�r>�+7�7}p�Q��V"3�����)��d�y�%6Sq�y9_蝝�^��
J�%��а�O�g9���駍i{m����\�~�N��`�g��`en�77
+�&LKf;�-	��!�Xֲ�k�5���������ٔ�:����1d�F���W@��q|�!k��頯B���G<�� �W|t-��35��t�r(���E��{�Z��~l�X�\N��1y��mJ�#"?XdrtXY5岒�$#�/K��[V�����f�<�2`�ϲ��\�h�<S�T��"����ȉP�bj�$Z�r`ik	�}�e��mqRk�k�ܐn��Y1����.�˾���QK�P7���lyҬʦ�*C�7G����'��1g?�o�sNb��)%�w	�C�|p0��}I�:sw(�"����)�>�����ԴT�?W�s�O��Rf�����6\`��iqMvqօF�d:R�Y��"��nX�ς�n=F�0�� ˄`d��Fq�r�#1���ך�9))��*�˼��v'��.�r^�vJ�W��/D3���ʓ;VAJ�Q�i�/R��$�߄���
��Fpe�x��V e�"k;]&���bau�Ip�LP�<���)|`o�d�fXK/(q3����/�x'ì�yq�;�F7en:o�2���Y�Q�M<��{�j�O���,.g���IT�S*ۓ������#�y#� l �� �f��g��r�H���8���.&�i�����I�H��[�G}�Jٻ���A��&d����ž���%�V��L#>}:��Q�%�� 9�����Ŀ6�{/�,5ޔI�s�{�w���:���,�Z����������`
�����Lms2F� R�/�+y3=�}i�;!|$�Y��"���J4� ������d��'���m�Lq���؇��h/O���geVFx����=_�]r}g���',f�F��S�p�Gc��,�nRЈH~�L1�h�^���ސ'j�(���^��%&ų�Mo��)^�O'�*yA)T�Υ���cpVhsZ�����b��}���Si����t���/bF�6�|ZPQk���D��g>� XF�Y��AU-��Nc'r�"Ϭ�����%�岔��'r��R�9�9Lw���S���c����19��5�T��Es\)��[ze�2�<��\��P&����Ȑ��`Jf���Z���'&���#'��N2z{�
Л��F��_Ҥ�	��9O�B�z	c$����id��z��N9��)ɿ>�@�c�B2�
�d���J#o'��nd���ԣF�3����ړ�$��^��7fJ�V�I���E�Feњ�u�Cɍ��޿�p=��au0z����,*'��R���;7��<VA/9^ڰT����]�>�A��PC���.D#\sl�	~"i/1�(�O�L�oV���J����b��B7H���E�Xn^,+ �m`�#`���Sg��p�:��D���h�,�1�6����=�c�Q'N����#s����R�%���y?���'_|��
���a,t&��P!��l�W}>ť?҆>�I[O\^��y�m�Y��p���]Ӆ4B~_�7j���}-|Ii����́�҇��p$IbB�܍���tC�}����؅�6�ZG��y�}�"���f�y�>�fR�/�������[��x���up�{kEK>HvB��(�u[kmX"f����͑B�:��c\�z��ɑ�M�/`�7�-�)`OHb����kb�&����2�<�/��w��Z��W+�.'I_��j��q$Ij�U�k���<ћ��&��Iy�[�`�fh���4;U����6 �6�����J?�ޏi׌�c;C�g�_�gCq���s�R:���&�1,&���>r��ң��{�XzP#vFy����pV���N�+�^���,e�����΍�ה��L�ҙ+��0�>�dǁY��٦�c��k�7��u+>�+ץ�~}�q��jֺ"�
�%etOV�|.�G���l�-f�:�Ls��f�&���;Wr/�uk�����k�Lek� �A0`-���n=���/�	��y����'B޾�Ҁ=,�Ԓ7^���D*hޑ?L�R��<�=	>x3L����Fc>.%~6������[ҟ��:�vm��'���a�Ɋ�0���kg͌��=�A΅4o��ڪ$��=i�v�S��VcP����}���xM-�s�U*��;~b��O��\N�	U�>-j���z�q$6d]��@ш��x�}N-J��2b��XA�0�yp�{��� "��A��f�f~B���\��`���!'�^�I�f un�9͔؛s(O&�=����56�1��1k?��U!@Y�Ym���0�I�l�oH�AV����՜g�o2c�ܞ�>������,�����DH��1X�������M�Mᓠ>��~rO7x B������6 <"��l��=9c��a��%����b���Z�$6(�+ĺp���ܥ��2kJICl���,����A=��k�jj?�ާ_�:��f4g$�A�.Ga����u'@���=�l⨠=�Lt���ep(�B^��Y��J
��1W��8�W[7i/������蚽����πf�ٝ|;�y.XJ=R9�i(F�R��X)�+��Ci�	�@�06v:��F#t��ܭ��7��{�fޖ@�9R�[�b
�u��nU���'ת�&��6	���1�R�8h�+��G����=�}��W0�x1���>�uD���9�+X
��,��/wrO���V��e1mD��͇��,�S��s#͒��1.y�#�x�����x�����d�)Sz<̖H�ߖhА�^2����ǌ.ǜ��ŗH��i���#8r�/�v����l��5�MV#w��0]��@�+M 8��Rv���ҋ$��U��DWA?�Ċ�d&S�L�xIb�Q[|5I����k���y4�]3��]T�����3�󼣣�_�Z,uS9��=��w���P�p5A~�n���xe�5�6`�A�,,Y}�BV"�D������M9^�=ac8S>��^"�,�|�}�)�rHﵠ�� �@�ڗ�+{
��n�s��,�٭�ڏ�N<�p��o!r�ȻY����92�1�~	�)8���n��v7�S��K�;^�U�\[ ?Wz�W�7c�}�jW�^�33A�=u����U����0�|T��H'�66#H�)3�B�&-㬔;5�~�����':_�Ɖ|�S%,|����ƢvKݙ:    ��fN�xX�R��K���n��#�3�&��Z�aR(��\(I�P@śd�R�K:ԉ����y$��HI����M����(�ZB�UaE"�8�6��sj�U��W�g&nR]�t��i�<f��*��FZ�C篭Oh�� oW��V�m֝�x��H��:*ͤ��$Nݞ�{�-��7S�mJ��lq�v���(��=�z�-m���Np_�o[O�9]vc�(��4r�͟�� L��[o٘o\d�ej��3���^��d~��[�v3���<5��>JS��*.��u1*�?1z!^ő���n>xO۟���eNq� fm�����L�kI��ـz�ȡ!p�p�a����M��|R�'d/��#�4�8�]���<_l}���b�\dK=�j���{11�kR:����=g�!?�֍[�-��\�^hu�R�O}�{�	I	G~���EɛJw�JZr��쀡�>�H�D�M�8�q�� �zI�LvP��"2�S�-8^�I)�PT/�4�D�ǿ�iiE*�$�z}E�1�`�B1��	�'�k%Jo
]4����:d�i+O�[XV�4�ދ�8�����r�ߊ��P�/��E�Ӟ���Y�;����ģe9)�"�~/$��V\�\�J���(hy>hc��=���d6�F���??%�ה���M�#�7��ЗkH\���qJvTe��3��]\с�/��*���"�.���É�*ݭb���\:���L�a�W���}���ܔ���@ʉ�`����y�d�K;��~G��� H���� t�=�!"Soy���\Bb��Ʃ	�T*垜Ҡ�p��w��8>
`�n�$�RK�{� ma�Z���'ܭ�xOH�y13s,��T�'5��'JɘH�ϸ�@���Q�\Z�3�h��I���-eŖ�,ZH%:a_�JB�+��Ǳ�wp����@�,5��ث�����%[�Q�^ر�y�,C�������M~S~�=�(Q)/�ϭv8�`N�ȳ�&��Y~�����Nl~[�~��=!՜+M1t˝a�l�.Î�����
�[i�~�{)��[��`y6X+����s:;i���d�Oq�:j�?����RpR�)��<��d����u�	׎?�9�R�v2�S���u���ffc��Yݑ��R�N�7���>���v����?��� �B���^�lm��=g�eO�~ `��-�w��v���bOL�l�t�̎8A����plf���.Qi�s��ӹ4���]8��?�(l�+� �N�ۦ��O��	4���|R�0d�[�SMˡʟL�{(}��Xl>{~�z��[r:0���A�y��<�')���U:�̩iJ����`��J[��37u�R�S�f(��=�o��t_3o��D��� r@�K77�L�,��SsĎ��;�	�ȿ3iU�+��C��M�7�
55:��D{�C�?q��w����M1�'G��J���]Ak˻��t�f��	d��;׳��j�n�b0̍�wf�%&FFXҺJs^kV� E�D�o��q����+����t�X!]���غMuX����6�Xg'���b{/a�ɪ$�����v[%��~���-9�� �����o�B%�A'�]�Q����Q���cZ��6��̧ھ1�|xG�+�7����囲�����\5�y��+�����n�}��|e�[V)Oz�����هs���m�J" Wԑ�_�s�� �k���{����&��b^���QGNԼ+Z$�P����W�<g�S��iK_0=��Ia�ʐO.Q��L��Ȳ��&�z�yF�R��YG�Ik7���e+��B�i�.��q�0m���&���=�y�GYz�)�R�q�x��K�Z-��/h�_��ğsϮ�\��D:W/���,%Ijسt>XH,�{6�L��YA�����7A�!�r`�|=<ڧ��tۄ>�)���e�R�[F��@{�ř��7A;~�X�?���"�ܟ���e����*��7���V��K9$�]�Ki+&�T���G�}2�L��sP�J��No��#-���;_�}u͡�� u���R�$�RM�N��j���n�F�)D�+}�>�j��ȧa�0�{pZ$���s�C�|SqD9��d�LqѠ�T<�IAemB��0�=�LX^�vO����HL%2Q�b��6��'g���G��,aW)�g/�[��ThOA�x�$����Ȱ��?�r�r��4�ćS���1&�B�q��R�'��~l^���c�5��wt�̌�>K�]�#�ڝO±�<?�qK/�۔<(� k�N��ޖ�
��"���zKq��0�׹̏f2f����qe�%`�L��&�%�
�y�`vjV�{0(��R/a��%#��S��y�[G	�1��N�����SG+m���J��h���9��8�l~b2Z�H'�{�q�Jn���Z%
���(-���Iyk30A���]ן;i��Ɂ�@JR�44�i̟|�4��ʎ�t�K��*�dvT������҃����>m��-��o����k�%�YP����_Rn��i=}J��tv���g/�	&��Vَ�X�[;���P��
�y��פ����Q6W��bq�"�rI�q��r;b+���9A�C�����ܵ!H�9};Q����|�ȹO�9:��w��r�5/3$
Oq*2
%�\?�t�g*~��9Uq �}�w'�Q¶��RT��k��g��[;�<eh�z#1RĤx1�Ud��_�_$���)a�%⶜WL�|Vh�zm���=�I{'50Oz=e��3:Q�߀��]��Z�_yj��i&AH~t鋫�3�?�S���䒖-��G�0����j=V.�9-��(���]�w!緼k4����].vn��G"��������K2�i�:7k� [�O%v�����H�6tڗ���(��k%k���ҡ��D�6_p����6�O8��nS��I�%�q^�ls| ƥ���u�s=�l�A�#QF��A({�;�)r��6s�G�m�.)�������۱Tߨ����+��S*�M?���!v���EO�{cI�-�G��٭)����(����'o匙2��.��yj�Ŋ�Q��h�Ee�ӫ�E�~��=>�Ɖ�r�d�4��7ۼ"��E��(��t  �sӃ䰪Y w������
��S�w{_6<�3m�F�+'�띑������?E�$����a x�H�%�j�z�q����%�t� �1$��I����f��Xg�������X&"r
�O4~���HR��x!�a�d����	dƫ��3��˿���78vw�֪�W�̼ˆb���V��L���ϚO�"����q椝cm���0�j'� E0�,!9<trPX�Sm9����N� `�4ll���\���X�I2��4]�r��^sb8ج�I�}�Y�XZ��,��av�-t���2�Pӊ��"V�Cb�Qi���}�-*{�S�@�D��4aZ[A2�|�z	�s���Q��v{���g�]�[RP�&f�i�xd'7�Bt-6%}ڐn7�o w�����7�XK��^&,�;ݚ9W��fx�ʜ�<����IiD��(��jzIA&G
&���J���#iX�!�b#�U&�0C{?�U�0a����X�d�>�����V��On�Y:�PM��K9	Vr�$4�������d��$��m��J�/��b,�9��T�v���M�Y̮���q�島1�K�Y8��Mj���lS�5vH<�LͮoK֔l�=�>�����pT�q�K:.m�F?����Zj����ׄa)E˟Si�±Ы�Sä������l��Čo@����V䢋,ȱ,����6�)!�?��+񡾸�<8�� ~��!��9�������*���wx�J��a�Jr��RƤSc�AT�!'��&*��L�B�D_%�q�1+q}�a�lo#��	�EL�E�ℴ�Mb��⻚�<��[~RY��),��H��=�I�/7��&$0��J𹩹ST��騡̃W��F=�n{b���R��K������I/�����͟�R�&��o��{nz�������Q�.Z��0�iy)|���w��0!��(:��2g���~�4{w�"ti�    �Ga�q�_U��y.��X�~�<�K-v{����#��#x��٪��:��i�a�I��8,LC���k��̰�k��s�6Ʀ5J�� T/�ԅ��U���g�ࢪ �x���I�L瓖�)�>`bz�Uj7y�S²J�cH˕�m�!��#(�~��G���&o�����B�
�%#���\�4�4"?=���Z���ui��|@x9��i��h\,gCߠ �g|�X�ӥF�
/�������:3X�n���Jm�P�ا�M�/���%�q� �ϼ��Ҟ�T��u��e
[�"����i�B�᱇�\�e42ʒF� �4����G?a=�Su�m$�~.y�kKG�n`�R�Ӹ����F���䵕��1	BL �|�%J�~0In�qԅ��d�����=s�_>N�f�	</ JʨM�J�l%��h�P
;n;��֪<k�-ٍQ������r�橠M���h���l�}�$������w�Z��%?nۊa���5j�oW돻ȗ	T�Vv�Wb���#����>��01l.<mN���4�������|�����\�à���(�y*㭱B~?�*��IR���E����t/	���h��%ŀP#�d���I���a��m���H?Ň�%5�ʷ�x$睦�X��'�������y�����b��q��Lỵ�c�F~K���C����..�%u�'(�dq����-�n�Ky�ޫ�x����+���5�,��PL�v?�	749��Ș��>�S�L����� %Y��{Ѳ��Ea)%�p��ےP��q�BO݄�m+�N�tx�S������s����=��/W�n���~�!o��7�(m�#'�jj�tHz�����o@[�'�A����!��-!n/��3�G�/�m��j-ͭ9��UZ)��M0.K��9��ҧQG���>���lVfva�_y�[��o��/��^�>@N���ҭXphħQ�H��j��� �D9��k@@X�vἦ��6�^Dx~n�z�wkc�����Bi�'R/M��N^H�f�hT��F,+�4�Lf�"O3����o`):'�D��|�Ur.�!Z�"��,�'���8�[���d8��]�Ԁ��]�[/$h>���?�eI��E �秸�q��7=��Xټ���;j1�WW��qs�4.(��%�E~Z�ٯ��>�׫ʭ�~C�'ǀxߥ����ț�_�IˍX�,�GN�k�0I+S	�K�DV4���7^H�%����MW⣏%��{�	BS.Q�Ԕ�ӵ@�5n�Rצ���W?{�M�r>����������c���������L�rџ;�w��i��7[o��S���nG��vk	����)?��No7S�~X}#!���S�F׎u��<leLs��zC	&����Q*^o��$�����璫�f-�m<(=L�ig�0#e�A��L{����M�R��4����kҌGK�S�T����F:MfhC�CO��+�a'�1�2Y�
����bjݛ��2v__�1sfMG��\N���䛩��	�7��	����f(�� C0��>rƻK[ ��"�g�Q���	\�H %�6��x��N����D��U/�� �����F�SW�})t��K�	��47�f���ƥJEz{���Y���q�?�-�+��V����A�A`ʯ�͛j AlN��\��C(�
 ���x&t��狦�H�8Ьx{\�pR��h��I�nK��,�GPB�<Xx��4U�"�.l��܌i��_BE��t�0"��J�*��J>3�4tor?M��4b�i�
�����EX���w^.�IxSJ�9MOBㄒ�}D\�A�,��	`y�6w�ߤ�*�2���qS�a���y���y�e����h����d�
���fw�� ��$:��%�:1.#�����6�.n������{`�Uv)�̌O� ��8�nO�\c~l��ʟQ޹хL�s�0j6�J�}AX�a8�_�a�Q¹�}4#h�m;�4�BW����Z��|�K��ή\SwF	��������0,sXy�`�m�%�li�N��K���T7��e�'��*	z�ҭ�FZ:5>I���`c��|Z��V�.jg���\+
����OGz�Tx˞���z�(�:�����&��%��_�y�`�]�'j����y=J�l)�T��%A�OW�Д_���Pbt�z<�Ǎ-�`g4�T����.�E�9���5�q	L�7� �H���ʵK���j8���F)��(8����t�gz����_.� ١����.Z��W���5ͻI\I>�Rr�cOFI-�'��-׻lBе�{�Τ9B�]:����9�$9��謱�})��2�}��RK:7�*�&	~�J���a�s�L�؟x<�	 ��vr���M/�{z�%���+ �p�6yx�^'"3'v%.G��r���/K1��i�2~A{��D��BF2��<��g EV��<����r��[��R-S;��k�[2L):7�:6�����\�yI$��h��4�;���Ԧ���˅?�>}nll�$�e�����~���`d���Rդ�ȗHJT����mR���O&z��������_�|�I_�3@�cN~�!gIz}%��S�0w�o�\���j�e���Ũi���f^RPS1ԛ�ݗ�\�� -1�"ɭѾ'�V�ꡀ���ܾ���V��)��yPO�2���Ǣ���<��+<�(�X���r��pb�Uu
����&�S_�.���s�zN<�a����1?I���I���Hs�D�Sb��2��O�P�"��i�a�s�G��ٚ���!���z�T�/؅U���a��=�g�e�=Ic��p ��T����4�{óbl���C�0z����%�cnL=��%�nIy�/h�������B��Qa��̪G��<��,��J�݂��T����nK��@^�t�1ډV�iar��()�GD��\����Mk�j�Ui���F�] ��Xa��I�9�J4HJ��4��-K�J��w�ЙVq�-�cK��{�����,�_�E�9��n�~���yU�l�e��B�O�S�X�?�cI&Y���� L�d�A�
�6���#5;N�5s),Ł���^;���^�<���5j^��ʭR@��̉�Jܨ�	��B�a��u���D�4D�����Sc�r��ݜH����m	ԯ?CryU4�d��d�rq�x��wJ���[�v�#cE�)� ���ۼ�/_*��S|d3���0Fbj�|HXNe�~��2qQ34���J<��bV�B4�	"�҇(|�ךO������5&��S2`*Z5~�T��F���}0���!�H+��x�	A��.sM���m���E�
������Yi,��3	0����&�or�+e�}TrH���J�������0�A����Є��'.L�cbt��R	�;&䟩Y�{ʍg�H0PLk�/�,�d�Pq�R���a3���5.f�&�5���
�^	X�T&��e,�]���e[���C�O���s�����id�Qr��9�}�(o��$Qa�q?T9R�!'���K(�"���%��DJb��'���d?c���3V�����̀�`e�Y�������Lr��S���pWZD�@�p��7�LB�\�v��qV3 �T)JvW6�f�}��l�:S���+.&�8^	*�Q���ѱ=LZ��i�n�Mg�1rU�M KPV�g�J���զ4W*�z�5;��I���U�g8v[Mn �xVS���2�4����� �1>������+8��d�
�}�Y�xh~Y����7�SZ�w=�X=��
{�[�i=��x+	L���(	iO_I���K��<�q$�
c����ڛ�|0_|8SBˤI�I}W����s�2�Z�4k��'�����6�Z'̥ �J��lK��'M G�+^:�I+�<��k��ɼK{���jB��醶�U��t�QJ�)<?�M	�=�R�X|��e��V9$ш�ȵ��5�2Il�='"]������:���o㛺���N�k���+BX�G�v�] Wl[\��鉥���E%��Z�4�S�+ �$v    ����z��L��qjd���ü�':�����j��z��%���]m�?��6��I�ۤ|$�X3�z�$�C��Z�L��7�3�c�_4��h�	>�Xtyw}��eJ��(Y�	��R��[I��?1�I���}���+�����zh�k����ɞrgz�V���o
�a8aq�*���xU�I~�x ��K圞c��6ZOy�LzёM_��ϑ.�m��BNp�z
EC��ep_��d&�����BYdM Cv�90�VE8p^#J�)�Yz&�<�T��,����H��T^�I�&2y��g�˺h�Οf=%��}>�Ep�tJ­HI����4��F�Y�4�p7�M��>#+/�������|�B�����#�/�j���i���ř�YVSL�ʿ��yf9n��*���}�&Ե3t�>K���;1x���0��G[?%�D�t�K �Q���x��SZ��B��=��O*�mI7��M�B�����B@��'F�g~�Y�r8-M����{V�-��Z{.R��T��r��c��y��e�:��xe侍;ʹ�E�J�z���б�ɟ��>����i7�lPO��7��P�Îc)��4!�<����{,��(P���5٘tH7���d�s��Er�a���<O���i �4�0�p�)J�:��B��N��fZ 0��mIEo^a����ύ4� m��a����J:I���yˌQ��Ͱw���ܔ51h_jp���%6�T��&iC�ә�Xy��́����W�j^%Fv�B'�,>�R���e�y��Y(�.���mq�UYwٜ���ְ'c�Cw�\� WوE��hxD���e�1��y��+A�����/VJ�Vb�A#�)�r*����S������������M�'{��'��G��6_%w��
~|5�T�5q��9��FDs��>���ӭ���v��T�=�-�Œ�C�Y��LKr���1��bq��Kc[�>il��.?�O�q"Z�)�ף#H��(U���� L�]���Rcw���w@�$O�H�K)U�y�[|3KO{7�`��׭�T(�i]�lI�6�̇4�ߎZҋy1x��D�F
+^�M�yRu5[�ʛ����PE���8�(˫%�p�l-�������r��-B�ݨ�[q-O�F�F���7=�s�>i�����%L���wO{�׵]����,]VF����~SP8H�Yq̐����䲛�$f}������<�� `z�f�g����#i���2?U���6b:˧zE��D�8���HzK�{�}�����k�ֽ&?�,�O�P��	R1^n7��Kt��!�7HI�p�;	;N�r� -�P��_�r���1�G��'��aa����y���S�g6/����S!�W�\���!���'9+�N{|��	!9~d(�疚j��o�~��9���^/�T���$�}�o�6J�V��J��4�dv*��������Ξ�&�����v��0���V��)�M�;ǋoA�p6��5λ�Zۜ_�5;�ʎ�LV�dA�x���W���s>����Z8�������W���r7���\J5X�d�/�b����XN���yѱz�!�_����;K�W� ��6"�8��i5����%�����*�� �w��wM�p@4�̦���W�t縷�'�� �ͭ�ى{A��u+F�lR{΅��d���KIW-�e/�����G�S2��"_m�����]&+W"@��S�Kйi|�y�l.���N���4-�so��6��d�9�R�-"��k��8�Qb�����	]_&�"�y�hC���U'!�~�G��L���J��O�D8��	��,��[g*��u�������]�=�����}{a�t�Hbb Q��쥦J��N�p�睍e2��~Hz���=�":���f�Mۓ�E~C+l3m�R�$y�4+o-�<�?��R#[P]g��K>)��c@Ӄ�����_�WQ����0XKeϴL�O
+�OߓO�4�{$��U<�Or��u*$�%E�y���_۪���A���a�rhZ�}d/�E�Zˡ�(`��@#S����Љ�M�}g���x2	Xv�\!Gغ��Ή��?f'GXjm�L "��{�?	�=��S>�b��m���M�]@�U��Ҵ�^�~�$Ai�ɞ�yH�����+h���yc;X?ʎǓ��z��V*��O���FؠE�J6�������|�C��P�>�����~4Q�dJu�U<�6| (��Ԝ*wN=�b�	�kC�HN�1=�r�Zk�J��q�	�$�;O�ox��f(�#{� �'�Ȳ8<�ŅN�w��gKc��7�-�%M݄�ls���N�NMUN�(��C�|lIu�ц�Wx:`�/x����/5OrgnBor�,��$�[[����.mr|�K6R�H� �/#�zM�[]�9)A��e��֙I�.�b���L�,�Fp=��f_
|�z��Ք��v|�����JD�IF�Z�����4�W���$B���jJ��;�?j���	�z$�7v#�T-��i��2��C���J�O����^����	ui�VC1�Go�X�r��vvs�U�$�&ƅ�~O \�2ؓh���s��Y�S���bQ���KlG1��t1�fDudc�I�������v´�+-�So��5�<7?^��+�M^a�s�W�Z�9奼�@�m�3?E�V��wq��r�^j!�.�e&Z_g~f4U_v|2P�4�b�@p�t-�F��
��x��E�U`�'�o��g�g�!%�qjD>��tzgi�]|0�Ug�%���.d�O_���N��)q��*sly�)���(�	8]2�9+o.�T9�E�䬜��0��K��,����y\z�4�ӛ%ԩ\%�KNj��;�%HY�"p��M��o�Y����)�E+���u�:���>���&��s�cclؒ��?�(�2�Zrå7}�س�P��P� ��84$wW��+(�'��)���iF0;T�Du��(��	���C�b�������@�J�S�a�k�`zJƤ�T�����Uw����MP� �(B�}���`��#wMjz����R�;��t `�E�]�
)�y&Vp�:��(��`&�w^�I$;�]�}�����2z��)/�<�SI6r��F�����T����(�N묝Q����6f
���{��Sbl��;g"����c�Г�9�!L'={a�2K%g�m���ד�SJ������NiX0}2��e��t}v��[@�X�**�ꯔ:q�i��=K.�%G�t�S��2X1K��4h��aV~�Ξ�>�S(�R�pTy�p_9�<.�f�����#�sL,�L�,���8��tM:澴��Ĉn��}�~�Q�>��m�(��^��&-�HLMW���LZ��+��>�B�|�^Z�Yw%GR��B�/5�	Uf�7=d��I-�U�N��b�@�c��.ׅ���l�dz�̗�g��5��9�������OTZ��%����ȗ����nf'�?6�W���񹉑���b1	�5��T���&���ޤ�	�I-�ѯ�!�����l�d�����ѱ\ټ���ВV��,^�#u���x2�����CP?�����C�}C��-�
W�;ہ[RQrށ�Ј�f�e�)��9q�vw#p~���5��(}/�@
c��� �@�Y�&0�� ��a��O��^'ʞ���Eǝ�e^��\n%)+�*�R��1�2m/�ÉA^~��D8�'?��q6���̟7��r�Eh1eA�iu�|��U5��~�l@��`k����dsk�cMA�;��2���rh<F�癁�W �{U�_L�{��f�^�������.���f���ڲ�fͨ��2�T�f��+*��b�nݬr�˄�4�4��g[���'yO��Nw}����6x��=|0���|��R� ��s��>j0�"�|'Wy�Y�^����*^�E�4��i�q�q����^����̅�/y݄l_aq��&��꬧�� �����R�e��f���K�v6e�T2��'P����,��j�C��B���H���!�]�F��2�;�B?�W)�g���Av!�@�H'+�Ha&��2�4�G����<a��A9�vT    8z\$r_.�y)n�RW���dgZ{���QL��F#��P��=F������$,�Y��EN�t&�;�~�4+.��IK�m����a���x l�o_6��:&�af��qY% ��g>�d[6�}���	����-�c��'�_\˧�*��v�| 䕙�Z�C$�gCJ����~W��#��;�q"y�������i������]V��z���_�.;��^ym�Ϭ�@J~M�y���4�s��Mp��I�������k���Eso�EvI��8�dp9E)K�E��E:�Aܗǂ<��T�U҉�z��r-�f�2{>��u�h9ί�La@�:q���)Q�K�o��gMy�ӫ�3`_�Iuck6�$ uD�T�КbRT�٣�O���qH�{MI��k����YI�ig�=̄�9*r�'.�Fqy�9j�k?)��+�!��ٹ��*�X�~I@MM��e�L�����6�^3��V�Z���e4�ģ%�?���9]#�o�Qg�
�e�$߱l�;��F�'���T��3џy�Vn��	8��Ըr������E�P�}��kj�D��MΔ�ˮ"Y� �Z��A�K��xv
J.f�h�� �)w�$�)���)� X7�dG����i?��#K٘���P���Y����gF��?��K^��|�-�Q:H�J�,���Ə�����ҝ�?x���f�Jd�~|��\����NZ��"�]5�R��p�h
B�0V��7���I:a���	&^��d��l�[��s���r�]��H�ꢭY�I��N�N�5p��JO9W�	2���ʛY�1��C�v# ����S����� ��	����v����w��#5_R�U؞����g������A|z�����{�s�w��"0�P��	1�� M��qA��?jL���y���z�IG`j�e]�s�NIbsR�y\p��S����j�㌚W��_���J��dG�^ι� �m�.aFp�A�g[��c�G���=�g.����/��K/3�[G�x;+JCVa'�i�g����)Yf�#��,+Q��e{N��Z�=�Ӣ��K	.	�HJnv�6e��D���P�s�\3�\y|��+[�!G�%KzU.۱$NK�i�wM�m=Y���s� x�-B�� �R��]}K�����˴�A=^'/gIg5�/��]��f%'�j��l��	c���Y�۔T5����p�7C�����cG����J����8m��N]�V��/�3�痬đ��X@}r�5��E[y�����Fm/)_�XN/0�̔0��e�+3���`18=hMiXC������̰sǛ��_��]#�F4���Wt����&l��^�mj�̛R�&9�A�w�Q�%�&�L�Ď�aZ�d3���MCg��R/�gJ����ґ�QJ�o�"������%�O5l�]%c���e_�mrc��5��}�yc��t�ق	J����q��Z��54���; I�`�X�сKV��<S0�b�2?+g�	�C���d��w�[�տY5x_TeTµ��X'�8APT&�����C�>�H�~��iDS�P���s�l��_j�Tz]j�>����%Lw����F�\+�mc෾w6$s5i� �HY��Kx~LMmUv�O���G�Xj<��hb7 ��@O��j���2T�xOY�$�dT��Vq�xo�f�'�j���'x��K([��������M�^�"�}w�dω>�ɖ�yd%��FA����� ۆ}Z�ژ/�C<��(*£=t��O��<)W�q@�;Wm0�."�=	�%�Vﮩ�o�uaUkj���{�>�DO�����Y?R�V�y'7�Lu����.WuWV=&�`�H���ȴl�����T�A��H����^�)�H�]�8�<�i�I������!��В'XU���G4ڟ(�.j��r��b��d�'���Pv�O���$YYg�0�-�R�@��n-�l�U>�f�Y���;�E��i8��L�$��S��^zfBQ\�tQZE�TB�~�&��L�ϗ�� �f���_7w^��5���G*�8�7�5�R�]��Ě��i��մd+w��_��<��"���>yEU����d����(M�#��k)�2�m��V@lTzD��meؑ��v�����D?@��F�q��m1EN��TH��6��1�F�Hk@����u�ʉ:eK<I���"�В��H�N����&`wji&�(�Ѳp>=+^�Z�S��j��sf��3��O�C$��iW9���9�r^��H���K`�[?��I���)#�_ÌF�7�Y�j�[������I����n�KH�\ɗ ��s�����+���KL�ڒ�]�cS����4����|�Ά�Bjc�J4BR4I�����l�,�6��!��o3�h �V�4k:�}!3�d*����Vi���s&�|���Coy��{�Z�ѱ��K�p���հ35]|�(K���l%���w�;�z���&�S�%cM���������KQ`�����c@�S ����<�v������XN&�����c��|�+0�_����I�i@a��_Q����e���\%��~/�jh�s�6km�������Y��C�#��DyI�� cHB��+瓞n�tt�u�������|,�S���n�>#�~�
.�J�. �M1B�c�ǳL����gf��c�/�#����駿s���t�iʾO)�6��n�-�f�i;�{�ԇJ��6S��W)KV����Ӛ��U���/������ �Q]�d�ɉ��f?�Z�$*%���5�40�)�&W������N8Q���T���dYkX��0����T�l�>&��^��Z}h*�;����ɢ�p<�.�T"��uj����8���e��+�`�>�;WC��xL�{�J&3�=�M��m�8i�?c��mL�D����L�M���2��-���7��:H󵊨�j�s��7���Q���ǼukD6�qq[`7[�R�oEC'�>�M�T,������8��-�I�K��aJ�s逾Y�UI���9%Z��.rRDB~�(f�N	~�﨏O�p-=�-��A�>e�ғ:���}�k^(G���(M�e4�ʷi���ͤ�4�UΊ3PA��
T	��C�?J)�C(��W��0���o]8��;�ޤS״��|�p���V�Ƙ�4G�y��y@$��΍^��R�?�%�����+i��*`22�=��o�� 5�Z� j{���j�wgeLY��p�������: ��y�ucfs�?D��N:6p#w�-']*��*k`%�����7b���f�a,������]�A>�7`2�2InI?�9�b'��|crQ��U=\���m[Y�$��	dC�)�q,]o��^�X����Қ����]�ˏ��m�����߸$)�J��O��Zx�1�1,�ݛ`��^���'j��4S�`;B��o��@�2X�O�&Qc�9�9��) G�w���1�d�l�_�u�ȷ�<JR36	Gs`��еR�,��EmX�r�jO����3�y�.� ���G�<�)]G�3b:�u9���ե��6v��\��$-�.�����=������U�z/y�ǯO?��K�R=P�9t�ߪQ޵��vVC��n5PAVF#Fa�X�"S�ZY�3��n��X�_��u�M�k�7A�=�&�cM!��R���_��?j�F����ROr�{��,s6~j�	����ef"y`�;B�VF��:�d{��Vֶ��cr�F������v��+h2�U5��;	��~�����^���/rL����D��H�ͮ,J@>ە�_;Q'��؋���k̅�L��_���lfO��"^��)����3���Q�%�O�$�Sj�M�m�ub��Ύ��Lx�H��5,70���H�N������;yQ�p�����x�Q e?�9Ʒ2�,G��	٬�3�<$ظ �|���MnS����U�O#/�o�w�(_\�jJ������z6Xt�p/�}4R�i,�
��&+j�޶J�SN�ݻ����uh��Y�!�;�N)����GM�>�<��S��l��p���w�,�E�^ܙY��W
�7�.�)    ��aͳ��4�<�*�u��7�M�O���4m�S�h+�?��e����5|�?=.Ӽ�,o2�,ꏺ?/���BT�=Si��Į��+}}���`ux�_��w��d�sD��R-�C��S<o�M��l�(��h���:y�|��پ��5��҈<�O��0?��H}fM>��D�L����<�(��Ù�U����z+|\��]��Q"��`5��5���K�0Rj����n=ϟ�߰w�l��n胏��ZAB�N~��pPv_�>$�_/�l���Mʭ�f�N�ؒzy�� ʵ--�N��7��|u̠Y�u8�������|jqA�;��jz�L�h�O+�S�uH�>��z+w�o�w�R�Io�����uj�k��,��^���>ԏ<���Ύ�CP�%ͳz����ژw�~f;���H�Č�iu5o�P(���΋j�=M�E�~��+�4�us�E��p���D�(Ч�N��c��ެE����g�J�m�d�-&Ͼ�8f��	���}�'q!N$8ݖd|����9jP﶑J�tD��E.�O�G��𚶂��VX�B; ���s�f�'wI�׊o��m�Մ�C�֑�R6-��Hǥ�А��N���O��Y��5S��k�������XݳC 2�#WlP(W��0}(����Y�W�_�������J�����J(�y�P13�W��������旦�}/��F�\I�U��W�8ח�.͙���|�����ىz�+��]����t��w��5Zj������y����X�z��S�'��~�}'՜�O���%�2������b-���u'�#��4~���Ӱ�H�t��)�����L&��~4�c��ϩ����}�#�	�D�,?��bIz���x��$�H�X�{����V|-��	r�����Ҙ� �k`"Wd`�`�z�eHt��+��ߓ�9=o�[륑�ME� ���є�*�%K-_��y�T��_B�<'��Ա����s�/U���4{s����SxEǚE	��-6������S��3�ś�>_?Hؤ����pP�n/Ǔ��V����('���O6��Ei��r�d��#h3kA;R�����|�q�'��'Ϟ���IR���M��tB��ۂ�����C*Ao*���� WBȩ�g H�֛�]�Q���P6�lvI�Oaq��%_V�4�z-TQ�+�.��u�*�����z�Γ�եDM̧pyn%���d�����w&Z� `	z�]�+ɜ���Z�vt��eT��SͱPM�C[��Y�❣�>пW��T�(�GO����%�����*�"�m���MМ�6lz6(tn/����V�do�)�Al:�u�️�ߜ�2�$�[e���>�3NNl���N�,6�oj� �M�_I,��.{1$j�y]����eA��>��$�g�2R${�<?��,�-�s;0�'A|9�g{�j��\���`U'��cz��y�Rj�փ{L4㷻s�o��it���ft�ʟ-9f^���MJ��'ݐh�t�������~�O��2-����	L�I�LRV�0y��Y��9TjQ���-q1	o���R��|���r���ѓ��J��� K�dF����D��8�BR���A�v�f�4ۚ��������&o۫q�F�)#�ŮR����� �+��W$g�w��k�jjt�p��{9e��z���&���LLߩ �YhI�n�HW#K4u��"b%�L���4�&	��K��ߓ9����u��O�����W2���3s��e��_��SS���`iDZS4���t>�������#��문*��kK	�릤"�������sK>���,�+3���+W����`��Ys-=&��F.1aw��J�e���d6D��T�k���J^&�O����#��~�ϑ��X�kW��NQ��|Sv&���מ	���βM��c�]©���W�?�f�.I�IE�\�އ����awz���A�gxhF�R�ȋ�������pG(}��7��I�$'��Cӕ�8����C!i�be�L�"�͑�D��Xz�*��ࣰL�3�������뽳���y�;�ٔ�&�Ъ�N���%��;�Ē� ⻔�bz^u�����E�?���l{��{����}0�K=�%h�����Vt�D�=�1 O��+Q�,��1��z1�z� ��]vT~k���:/��͠��y�T�r֟�2��ˬ�P;5hb�Q"O�Y�d1If�C�x�_������������,��V�n<�Y1��_R|���>f]�{IG;Q��|�Y��y*=�U9%X����6�ɑ	�,�^b�Kb��G��$�&:'`u� j�d�@�'�kֶ2��W��DtY�1�:y��/G����Fߋ������O�D��mf4����%��T�3+���ѓ���1C(q��qҡ��˷Fg\69�^�A��S.Vt�8m>����3ݮf�Q+��h������^�����c���s�|���n��#d)�f�\���DXs����IH�(�()6BM�N>������z�HjoҁeRz�~9��?�0��,]����|��6H�a�T9C-m�%���r���.4����m�o�R&�� �Lu��hI��K���{�f�5�f|7��=߆g��b��Xrk�\1J#�ւt߉[�\2���$1�
o꧙���C'�̷�g
q2�� .���4�el��8qy�|O�������D�{�3ͦX��0�7�3��Xw�mqXފ#I�;ŷ����/���'����b��6*9���7b�l�<b��\���*9�X�l�j�T��%Q��8���t�Xι�/���w�b�w�tIy�� Љ�Ȝ�!������E:?/C��e�r�����ńtp� Z�O�Y�s�'ϗ�?���1/X�����QT����'���^H��ۓ�0�ZJm�XlY�9߅C�~��Q��HκN94�G�S�h=��ZJn�s~�����k�b��y�k
�]O��� �3X	��Ȅ�c�p>,�/��d����7�lO�g�J�qh�$�U�<�UB�jfm	4]� �٧�*�ăo;KZf$�Sߗ7��J���)�tB���v����f�����Ϋ�K#ױ `�8���ԗc����p]_����
�;qˇl��[37��d�%?��=L�K�|�]f�6�v �Je0�`�ܿ,0җ����Oza~tc��K�D�=؝gԔ�|Q�_SEe���|�UyΣgaMJ���IyU요�-�&���~lAY\�Fqf�[!��8�S�S[Ӊ|���!q�2BZ�����w�d�&����xLШp�n*3p���0����šsJ�Ht�J�n� �Z
��
�3�/���bc:�ֹ2���Ͷ��OAS��H^�4�P9"��[�|s4&ZB�ۏw�Z���<�9Y6HK�|IK7��k�;�CC��F���r�i�Bk��1��y/G.�$Y.3�f��<ܱϛ�*堒���z򢷦�;֮������;M��I��ET�@�gC�f)w�7 ��LQc:�s祬���,LS��i>u��^���M�!�ϰ�ߛ	���C�P	+꨾A6��᦮[_�e��E�e�<��/"%9��F0/τi�t�ǲc,d�e?}�nԳ��"t3Mƻ�����tB�vJ_�q���b��/џ��S͹��e�Z
��Q��t���:-�Y��L���w����#0۶�$�ŏ��m#j)���|�m�Q�yY�r��I	-'�\<~CM;��8>~f\YF��dS UҦF��rwh�"�yBp��l�預�z�����rҵbj��έ'�Ŋ�� ��a�|��Iu�S�SJ�%=(����'��/�VEND	�H��`sX�inv XP�<�[^�μ=y[2�{���3��1N��R�����%��whD�(M�Z�_r���J)u]�"�� T�a�`4 ���{�Zc��jSχ*̪�y`E@=�l4�j,�}��9�iv=Z���� ��A��D-�b���0#���E=?����tg:3����^W�V��j&�wa|N��&�    ���c�!=��Nq�=���SyN��m}Lt��� kJ�jI.W�1x����)D^���q���F8���W�	�{�
`�d_���ɒZ��m��ƥ\��dR�j����1�5��5W��j�썜^�R2!i�b�磨?�-��)�� ��
�{k%�����ød~%�O=��ެlO��$ɏc QZ�h�,N�r~(����̯<!�N��v,�Cs��zr��|�C��Rcʪ)!�/��2����y�j�~�ls�d"n�[��a6 ����?@�".��Ƀw`_0�X�Yt��Oq����qk���C6�*�LA{f{�G�w����8��ʘd���,�or�!�����Mʾa!;��[A�^�	�.�vW}�I��O�MU�$�r��n4{����`_�A �O��a4������r'��ʶ�AB;�Q=�����b�H�3���S��[�+��Ӽ��k6Zj��[�u�5l&N�SVA�d	-����ui�e]�%�F[Zy���O��2�LI���	Y�6�c�r���M�%�����V�,�N�m^�_W�x�uM����+2�r�mGnB��u[����B����������Q,S�-Ҙ=o�[d(��5=��N�Fe$��7�D�\�ܒ����''G䉊E��+�Nk�Ƅ�FG'kE{x8&���瓛���H����u�����JɄ^L�O7���F�3U�9�ri�*����4��f��1 ~ΝqՊ���fd�d_f�.��4M����'��K�����mD� �E�ԣ[�<LnHr�,fA�|�Hх�:R��ԌIrRR��Ku�ҝ�GG��,Y�r�%.QM��L0_O����Oh���y�x���V6��;Uz��Y��?��>�:�ۚ��@����k��BT����h��Kj>?��uG�k�x����$RN��%B��G0{�H�9���ԭ��h���!m���i��O�:��ɈV���*Q"��)x��֠7	&!\!��=<>��q�#�{���RN%OHF��1�S��о�\y*[� �����,0������h&��� �r�j���m�����G����g�͉�IA�fG��� C���5�@�B�|'������~W�e�J����!�9���0�E��:ٞ`���Ĩ����&"'�]#�A�:����R�u�]�E�@3��l����E���E?Y ds�6d}��{l)yRK�WV��F]vǖ��Z���*Ň�����8	A)v4J��2
""	놶嵛�e�8���tS;��L9�Ꞗ|M�gQ�b�<�!���|k�e��|t�-��HZ��s�����-���)zլpA2�P3肾G5N/Lē��	销��?�����-1eϥ���>�U#������V��y�p�O��������Hܚz�42�8?��*�����Y��'��[��j�yI�g6���<����l�f죥�^�91~��P.�֬��u�WϝZ��ll��﬈֓�� H鱳��oc>����0v��3TU%,9��n�"fJ��Fi��Ҵ_�<(Ћ�YKj�(7�E��#s7�w�
�m�	�]�e�e�����IՖ�.Tߺ�WH��c9��џh��3[�8�nT���v��k��mj*�mv��l�$���$[�^2K����2���[����bh�/7�{r�vO�+�u�u,؛I�;6A/ �݌�S�b�%}�|��+ {%(���m��l����g4�dr���}R����.�¾ �J? ��x��g�eȡ�PNY&zB�6Q
Ư�%`~�#�w 9f?����$�h_J�A�2�ϟ�����ml�Pj\�j��dt�����vN����stj1 ݔ\c�����\,�������}矂E��2�՘�M���c�D�^aΤ-7�am�5�n5 ����]=
@�՟!T��a�T6HI�(���\�>���@}�l�l/8xHژWu����T�����D|9+B�J?<�S?x��S�i2n�q2*�A�W�����8��9	�����/�iV�z����e�h��������ׂ��G������zb���s��@��:r�@Ic�����c�e��Z�zN����]i-ۤ�&-ї���<
�(�h0��[2LI�:W�dk�Ɩ4�D�M���=:�#	�3w�&ha|s�䧭��Z|�c�#j��[�R$d(�.Jl�`�V)�i�$"�9`�(��X�$���*w�4�����ؗ8궀��mx��|iT~��Bg.��Fe�ᾇrt}�KP̔́���X��R!��|ȍ�����g,�& �APZ��!�����>$^��-���!;^����7?M@ך���i�d�y��Er�V>Os'�q_s�!�Ѿk$��C2�C�
r %.�̗�������R����/�>��mFǹs�Re�Q��P��KM�:�&��#E��|4�w"?K��*0��)*���)����F)��{&}o�ɾ[j��C���8L�6��(4�j9�1��{p�h�\3� ��Į���˪�V���|9q�����[��c׊�NN�oUd�:W��VV>�f����d�t�R�&�)�2�֟�W��^�X3֏�L���o|γ��]x�NZ��� ���̳�p��y��q޷B��"*Y����<���\�~Z���
�q�5��NN����p��z������z$gօ�g�����V	(�K��cx��I������>�I�`�;k|�s�їG}6]�Md�rIф����+��^r��xm�(Z�B� ��9��%�|�:;�򬝼^nb-�M�S:C�/k��7�NU4�X��r�-[��z3^y�h;��(�3�]�a`��^y���g�p�����<U�����V� ��Ql���U��s��0WQ��p���6'J@�6��G�vbF�����Nh�Íp�K��P!&M)�Y�?�B�]���96/���qX��:XTȘ/���4�z���G�n@1��%��{/��Akt�U�0<�� Z_p���ȴ�t��q�ip�L�~/k�;�����̏d'rگ����� ��&�#��ǁ/hE*
9�'�A�[��	�5�_«T���j�1@#�{� ����snO�*ML������9)5�H�2=�}7�U#5IA����	��ہ�8����5�sލט��u/l�����dk��)f�%Hn1���ë��Dj�����f�>��Hj8�q�9濂mq�3.d�N��OTG/A(��MT{���U�f1h�tM�DK��t+�r�j���	���b"��|�b�D:��ɑН��_�#;RR�Iw:E2��	�f��qp}��^{���3�}�"O�\��c'�@�@�;���y�Sn��W��fObk>�2m�CO�IL��*�#I�[6��~��4�o�؋������U�9�J��/��`�C觖�8�b�U�����w���`��=�J�^�|o�
�Ґ�ŵ)��9ȑg�}�nΑo�y-�e����cv(�AR��o��TY�7g���gc�3�۝�Z��Z��W��rt�r�J��I�] �).UC�$^�Y3���q�x.g!�Q[n��lВ@/ڐ��$
��P�K%jpS>�$�Q�������2~��?G̓�4�K^��7 |���b��+���,�W�$$+�ȇv �د@G���ڪ8[��yw�g�Y>���:�"`�b���C!��F	�M)��ƟfR>���(�(XJ������� ^��g�\�|N(Fe�����k�kS~���c]K[�|�$�ᶚb�2k��s�K�RΑ���HU�6裒�I � �z@����j�F1���Ut�r��� �!N�<"�*���&Y�'��cxo�9*��]8^��|��\�(��<�R]X�D��ne~yB븐h�?߆��t��5�yq�M�#�
V�^�Dj ���b8.M�%[�ިKQ@�x���hOKW�@tΣ.��YL$[6��K���8!t{=3�Cmqe5)r�T)8��W�����elx�D�)�&����X-M4��MGy6���x���������l��32�S��mw��ȾS��ś�ʽ��g&��g�z��!�8J !  �臃���f���*���t�o$�xK��U�UW�B���[ȕ�([��^����e�s ��5H�˖�kV��c+J�T"U���u��u�Rd�(y�nb1�6
G�7l��~D�bt+(�����x�-���48S�{��?�����9���9^~�tg���O�4O�p&3ia�C�y�q��$_!�u[���D�����Q�#R@��!��ob./���uJܛ�T����2�����Ԣ�(��zq��("�y�y�s����G����%��XlVH�U�e��d��v~y�yB3�C��J���r�d�r�Uԯ�*�1�3yĤ4˛�"	�ӤK^�CL�!5��#�&������KB}>f��?^���`������~`�I9S(so�H�w2`2�'�
�1����$ҕ�O�uR�G�Kf����d��ɻ<��&JXgh��>۝�-:���({۵�-�h0ˬ��-!�<���x;��!^Ǔ�%�qH��W����Ku����^��?��e���j�6�킾S��
J��������J���U�<{�#����K���fH9(:T��S!�p�B�-"c5��C�X����w#�{�}h/��T^�ax�2XC�oI:ߜ6���հ���%RN<f��Φ<�q�r��/���'F6޻"�xb<{���<�_c+���'A�Π(���G�F��i�}"z0�}��eВ8�GD&��Ȫ�6��^���p���<�,��y-�]��Qz$	WSi�h�������ԏ�����d�+Tq5�����U'�ٝ���K�� I�l�z[WN#U8b�[d�0oO���ߊ��e��l�M93�?sDg{h,��£]�#9�-��\���\�!|���d�t�����#%�H01�H�G��̌n��\j͔ φ�Ď��I%bR���2q�wT�s��&]j��&m�0J���dc	�h��6�c���7��Ǆ�=PN�iv���g6��*B���l��e��k�}��[�J�r�{>�o?9�o����d�1�P�˭N|L���>9�>�M i���ܨ"�{1�A;�+����,�c��Yc?�Et4�8lv�2 K�$���.����/5�p��s�_�_j��c�.�v�7'���&�3����K�D`��0p��xO�$qh�rHt�.�\O�c��'Y��5a<���f��&�)YX�߿
 �vȗ���#P.���xQ�����فSf�S������u�S�_Iڟ����z��H/^`��N5�ҡ_ģJew�e��F����霑v1m#�|3�?T�8P*�$9{�3�>I��}���V�{�~�����I�w�U��Q��<t;�-K/��w�@��ԗ7[��������6�v��|G�d^II��Z0y�0t�z�E��@���W����m���f	���Q�� �����{���=#f�_	;����R��\\r���W�/��I!u���@��ъϥ�U~�3͏���Z�)+��Bt&w/��C^���h��0�˻��P����-q|�ztc�Ep'Y:�ۜ���&� �n�jR�]2�u�0 <n*P����ަ�)�rߏ�]�dH]�Ay��Ɖ���䜾�F�^�����V��A�z�M����}�1X¤8S]'�<���%��Aa��2%X��Y{�%��{ʏ��B(����$uk������_Z��Q��k$~�$��8rZ�>>5��S�ͽ�n@o��\��Hai�V�Ѳ�~����O��LZ߬��%��w���㧱�}j��'L�\��̙U��=�h���+�caz�p�8�K�(�b$]��l;#�V/��,��䋓����e�;}V�Vz�`F�m�4�����,��S��bC���<��O}/3��LF�ފ��4��Ó�HňG���7�yS�'�R�7�қ�K��Ē�<�!x?�1��a���U�7�.��L�.OTy<���=��ٽ���^:�Y(Coz�wg��H"2�^��!����5:��&����j��9°��)����?��nou�<��������>��%r���\��RGk<�
Jp]o���S걢�������b#)u��n�@lc��<�(��6/�ּ�,��,�%�O�w=���Z�R�2���N�ʮ�\떗S<����I�fi���SB79=?�Q��� |�1#�	6��������ȹ�L�,N��c �4j^��?_�h�8]��+�Ρ�	e�1ѕ�S�0\S.��s���y���:��|0��jy��$k�v�| !�5Ё��M,Ua�7�z*�A_���Syل��s6f6�!�1}e�����]����༖WY�?� P�qj�����Δf����O9*XG���Po�2���W�
I�L���V҄��HLsa\�o���,����9�L뚪�]t�M6ѾR^?���Ok��5��ҡ](�'Q[�����%V�%[B!��Y�G��J�J��,�lGz��f���K�\P�!#n��2c~R�@�S�W�ws��@����>��o�b�M�.�1��7q�!s���ôs�u㓞\���(��[�/ۯaO_̗�/ X��b�G;A/��T	w��`#nq���3��t%�$Tg.��ج���;e�N�1Jj#�l�F�4R�bialt�Mj����̓�W�lLg<p��,{� ?��%�s���y4:�:O�iT�yE{�Rޛ��S��>x��9&�:�j�	�!�X���p,�ՙ�FI�}Bko4U�yY��D��O����b�^���'���w�)�$@� R/�8ܒE=�i	w�R��e�e{���F�ɕ;J˨�jQr��S�<XG
Ԥm�;E�"!(�Ԅ���[^:�A�}-87S�R#��:�����P� 
�W�6�>��\?���?�V>'P����P���+)���+�Бc��hP�K5��⍧j_S��PR'K4> Z<i:��/T��}>�5\� (�ȹ�,�}!�*�ra�מ7����1�#��+S�(����&{g����R�cRR�d�w;*`v�V�0��H2��,ʂ����9�!紭���y)��S8009t ��Z�^;��4��b[��t%��Rh&;���(�F�]�$��Qg��w#9�k�nۢgN3�y�n\��WM>qn{5O�0��ξ%gM�4J%)���&�B^6�J�,�Y\t��4E��jS��5�������۱��4���ʃ�VJ�TWMSQ��k���j�t/a���&�����gmm?�����L���cL�H�n���tϊ�T�a�i����r�h��݃��)�&���G^��"��y{@�d�0�Z�ڍ�U�'8�G�g������^ىJk1j=�Z���I~���M���U�R��l6gi,:�. ��>�<�I��!��ōˑ7K�K/��O�ׄ��V�����/�{�: ����$t�4����!z^r�AM/'����Ʀ%�4�1�jr�����ӚG�aҧ�[��[�{��+����d���QQ��ٓ@����|Ll��ג�E)�����w�E�%9`�čv	0b�C���D�xO�f��^�c_����̪WLfr�Y���t�j�Ҁ}R�c�]� @���S���_c;k�9����?�����ϗ�      L   �   x���v
Q���W((M��L�+J�J��JU��L���uJ�S�Ks�Kt���2�5�}B]�4u�tԋK3�r2��S�5��<�b���
�
�e�Y�Դ�h�)�|`�a6-| ���Vq`�a6��� 6��      F   �   x��ӻ�0�ᝧ�$�X�890�L]�:��rxz��F�[Ӟ|M��i�'ׂ�Yq!�ly��d?@5�@^?��H�5����.�%�����ġ�K5݂�V/h����w�_��d�h������O,:P�<�Fh��-���Z"R`ی%��G��p�*���چn�(�;���[���CG�?^
V:r�pun�C+91��&Z��Y��MbY�g�      H   �   x���=�0��_q�c�;N$AWS�b)
���v�������M�$���Iv�g�Kq��M��� O7;b y]� z4Bq���%J�c��W�n+,�k��\v���J��m�P%����v�A�/�B����j�R�X�d��оD-��C�_p�*�/>a6��;M���JY�����q���a�      J   �   x���v
Q���W((M��L֫J���J-K��JU��L��!�D�����Ĝ����|��̼DM�0G�P�`CC3�\�
uMk.Ojn4܂V��(��.��J-Jͣ��&:
��4�8�� ��F����4����40��0ù� ��     