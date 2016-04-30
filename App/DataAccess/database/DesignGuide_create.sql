-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2016-04-27 10:38:59.95

-- tables
-- Table: Endonuclease
CREATE TABLE Endonuclease (
    id integer NOT NULL,
    name text NOT NULL,
    descr text,
    CONSTRAINT Endonuclease_pk PRIMARY KEY (id),
    CONSTRAINT Endonuclease_ak UNIQUE (name)
);

INSERT INTO Endonuclease (id, name)  VALUES (1, "Cas9");
INSERT INTO Endonuclease (id, name)  VALUES (2, "Cpf1");;

-- Table: Experiment
CREATE TABLE Experiment (
    id integer NOT NULL,
    user_id integer NOT NULL,
    name text NOT NULL,
    date datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    descr text NOT NULL,
    validated boolean NOT NULL DEFAULT false,
    CONSTRAINT Experiment_pk PRIMARY KEY (id),
    CONSTRAINT UserExperiment_ak UNIQUE (user_id, name),
    CONSTRAINT UserExperiment_User FOREIGN KEY (user_id)
    REFERENCES "User" (id)
    ON DELETE CASCADE 
    ON UPDATE CASCADE
);

-- Table: ModelExperiment
CREATE TABLE ModelExperiment (
    id integer NOT NULL,
    experiment_id integer NOT NULL,
    query_id integer NOT NULL,
    location integer,
    length integer,
    model_organism_id integer NOT NULL,
    CONSTRAINT ModelExperiment_pk PRIMARY KEY (id),
    CONSTRAINT ModelExperiment_ak UNIQUE (experiment_id, query_id),
    CONSTRAINT ExperimentModels_UserExperiment FOREIGN KEY (experiment_id)
    REFERENCES Experiment (id),
    CONSTRAINT ExperimentModels_Query FOREIGN KEY (query_id)
    REFERENCES Query (id),
    CONSTRAINT ModelExperiment_ModelOrganism FOREIGN KEY (model_organism_id)
    REFERENCES ModelOrganism (id)
);

-- Table: ModelOrganism
CREATE TABLE ModelOrganism (
    id integer NOT NULL,
    name text NOT NULL,
    descr text NOT NULL,
    path text,
    hash integer NOT NULL,
    CONSTRAINT ModelOrganism_pk PRIMARY KEY (id),
    CONSTRAINT ModelOrganism_ak UNIQUE (name)
);

-- Table: OffTarget
CREATE TABLE OffTarget (
    id integer NOT NULL,
    target_id integer NOT NULL,
    off_target_id integer,
    score real NOT NULL DEFAULT 0.0,
    CONSTRAINT OffTarget_pk PRIMARY KEY (id),
    CONSTRAINT OffTarget_ak UNIQUE (target_id, off_target_id),
    CONSTRAINT OffTarget_Target FOREIGN KEY (target_id)
    REFERENCES Target (id),
    CONSTRAINT OffTarget_OffTarget FOREIGN KEY (off_target_id)
    REFERENCES OffTarget (id)
);

-- Table: PAM
CREATE TABLE PAM (
    id integer NOT NULL,
    variant_id integer NOT NULL,
    sequence text NOT NULL,
    survival real NOT NULL DEFAULT 0.0007,
    CONSTRAINT PAM_pk PRIMARY KEY (id),
    CONSTRAINT PAM_ak UNIQUE (sequence, variant_id),
    CONSTRAINT PAM_Variant FOREIGN KEY (variant_id)
    REFERENCES Variant (id)
    ON DELETE CASCADE 
    ON UPDATE CASCADE
);

INSERT INTO PAM (id, variant_id, sequence, survival)  VALUES (1, 1, "NGG", 0.68);
INSERT INTO PAM (id, variant_id, sequence, survival)  VALUES (2, 1, "NAG", 0.0132);
INSERT INTO PAM (id, variant_id, sequence, survival)  VALUES (3, 1, "NGA", 0.0020);
INSERT INTO PAM (id, variant_id, sequence, survival)  VALUES (4, 1, "NAA", 0.007);;

-- Table: Query
CREATE TABLE Query (
    id integer NOT NULL,
    name text NOT NULL,
    homolog_sequence text,
    location integer,
    length integer,
    type text NOT NULL,
    downstream_offset integer NOT NULL DEFAULT 0,
    upstream_offset integer NOT NULL DEFAULT 0,
    descr text NOT NULL,
    CONSTRAINT Query_pk PRIMARY KEY (id),
    CONSTRAINT Target_ak UNIQUE (name)
);

-- Table: Species
CREATE TABLE Species (
    id integer NOT NULL,
    genus text NOT NULL DEFAULT Streptococcus,
    species text NOT NULL DEFAULT pyogenes,
    descr text,
    CONSTRAINT Species_pk PRIMARY KEY (id),
    CONSTRAINT Species_ak UNIQUE (genus, species)
);

INSERT INTO Species (id, genus, species)  VALUES (1, "Streptococcus", "pyogenes");
INSERT INTO Species (id, genus, species)  VALUES (2, "Staphylococcus", "aureus");
INSERT INTO Species (id, genus, species)  VALUES (3, "Neisseria", "meningitidis");
INSERT INTO Species (id, genus, species)  VALUES (4, "Streptococcus", "thermophilus");
INSERT INTO Species (id, genus, species)  VALUES (5, "Treponema", "denticola");;

-- Table: Target
CREATE TABLE Target (
    id integer NOT NULL,
    variant_id integer NOT NULL,
    model_experiment_id integer NOT NULL,
    pam text NOT NULL,
    location integer NOT NULL DEFAULT 0,
    score real NOT NULL DEFAULT 0.0,
    spacer_length integer NOT NULL,
    CONSTRAINT Target_pk PRIMARY KEY (id),
    CONSTRAINT Target_Variant FOREIGN KEY (variant_id)
    REFERENCES Variant (id),
    CONSTRAINT Target_ExperimentModel FOREIGN KEY (model_experiment_id)
    REFERENCES ModelExperiment (id)
);

-- Table: User
CREATE TABLE "User" (
    id integer NOT NULL,
    login integer NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    initial integer NOT NULL,
    CONSTRAINT User_pk PRIMARY KEY (id),
    CONSTRAINT User_ak UNIQUE (login)
);

-- Table: Variant
CREATE TABLE Variant (
    id integer NOT NULL,
    species_id integer NOT NULL,
    endonuclease_id integer NOT NULL,
    name text NOT NULL,
    seed_length integer NOT NULL DEFAULT 10,
    spacer_length integer NOT NULL DEFAULT 20,
    sense_cut_offset integer DEFAULT 4,
    antisense_cut_offset integer DEFAULT 4,
    guide_target_position boolean NOT NULL DEFAULT true,
    descr text,
    CONSTRAINT Variant_pk PRIMARY KEY (id),
    CONSTRAINT EndonucleaseVariant_ak UNIQUE (endonuclease_id, species_id, name),
    CONSTRAINT EndonucleaseVariant_Species FOREIGN KEY (species_id)
    REFERENCES Species (id)
    ON DELETE CASCADE 
    ON UPDATE CASCADE,
    CONSTRAINT EndonucleaseVariant_Endonuclease FOREIGN KEY (endonuclease_id)
    REFERENCES Endonuclease (id)
    ON DELETE CASCADE 
    ON UPDATE CASCADE
);

CREATE INDEX EndonucleaseVariant_idx_name
ON Variant (name ASC)
;

--
INSERT INTO Variant (id, species_id, endonuclease_id, name, sense_cut_offset, antisense_cut_offset)  VALUES ( 1, 1, 1, "wtCas9", 4, 4);
INSERT INTO Variant (id, species_id, endonuclease_id, name, sense_cut_offset, antisense_cut_offset)  VALUES ( 2, 1, 1, "SpCas9 Nickase", 4, NULL);
INSERT INTO Variant (id, species_id, endonuclease_id, name, sense_cut_offset, antisense_cut_offset)  VALUES ( 3, 1, 1, "SpCas9 D1135E", 4, 4);
INSERT INTO Variant (id, species_id, endonuclease_id, name, sense_cut_offset, antisense_cut_offset)  VALUES ( 4, 1, 1, "SpCas9 VRER", 4, 4);
INSERT INTO Variant (id, species_id, endonuclease_id, name, sense_cut_offset, antisense_cut_offset)  VALUES ( 5, 1, 1, "SpCas9 EQR", 4, 4);
INSERT INTO Variant (id, species_id, endonuclease_id, name, sense_cut_offset, antisense_cut_offset)  VALUES ( 6, 1, 1, "SpCas9 VQR", 4, 4);
INSERT INTO Variant (id, species_id, endonuclease_id, name, sense_cut_offset, antisense_cut_offset)  VALUES ( 7, 1, 1, "dCas9", NULL, NULL);
INSERT INTO Variant (id, species_id, endonuclease_id, name, sense_cut_offset, antisense_cut_offset)  VALUES ( 8, 1, 1, "eSpCas9", 4, 4);

INSERT INTO Variant (id, species_id, endonuclease_id, name, sense_cut_offset, antisense_cut_offset)  VALUES ( 9, 2, 2, "SaCas9", 4, 4);
INSERT INTO Variant (id, species_id, endonuclease_id, name, sense_cut_offset, antisense_cut_offset)  VALUES (10, 3, 3, "NmCas9", 4, 4);
INSERT INTO Variant (id, species_id, endonuclease_id, name, sense_cut_offset, antisense_cut_offset)  VALUES (11, 4, 4, "StCas9", 4, 4);
INSERT INTO Variant (id, species_id, endonuclease_id, name, sense_cut_offset, antisense_cut_offset)  VALUES (12, 5, 5, "TdCas9", 4, 4);;

PRAGMA foreign_keys=ON;;

-- End of file.

