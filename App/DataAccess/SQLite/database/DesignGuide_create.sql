-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2016-07-06 18:01:33.241

-- tables
-- Table: DesignApplication
CREATE TABLE DesignApplication (
    id integer NOT NULL CONSTRAINT DesignApplication_pk PRIMARY KEY,
    name integer NOT NULL,
    descr text,
    CONSTRAINT Application_ak UNIQUE (name)
);

INSERT INTO DesignApplication (id, name)  VALUES ( 1, "Knock-Out");
INSERT INTO DesignApplication (id, name)  VALUES ( 2, "Knock-In");
INSERT INTO DesignApplication (id, name)  VALUES ( 3, "Activation");
INSERT INTO DesignApplication (id, name)  VALUES ( 4, "Repression");;

-- Table: DesignSource
CREATE TABLE DesignSource (
    id integer NOT NULL CONSTRAINT DesignSource_pk PRIMARY KEY,
    name text NOT NULL,
    path text,
    sequence_hash integer NOT NULL,
    sequence_length integer NOT NULL,
    descr text,
    CONSTRAINT ModelOrganism_ak UNIQUE (name)
);

-- Table: DesignTarget
CREATE TABLE DesignTarget (
    id integer NOT NULL CONSTRAINT DesignTarget_pk PRIMARY KEY,
    design_source_id integer NOT NULL,
    design_application_id integer NOT NULL DEFAULT 1,
    name integer NOT NULL,
    location integer NOT NULL,
    length integer NOT NULL,
    "offset" integer NOT NULL,
    type text NOT NULL DEFAULT L,
    descr text,
    CONSTRAINT ModelTarget_ak UNIQUE (location, length, design_source_id),
    CONSTRAINT ModelTarget_ak_name UNIQUE (name, design_source_id),
    CONSTRAINT ModelExperiment_ModelOrganism FOREIGN KEY (design_source_id)
    REFERENCES DesignSource (id),
    CONSTRAINT ModelTarget_DesignApplication FOREIGN KEY (design_application_id)
    REFERENCES DesignApplication (id)
);

-- Table: Experiment
CREATE TABLE Experiment (
    id integer NOT NULL CONSTRAINT Experiment_pk PRIMARY KEY,
    user_id integer NOT NULL,
    title text NOT NULL,
    date datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    validated datetime,
    descr text,
    CONSTRAINT UserExperiment_ak UNIQUE (user_id, title, date),
    CONSTRAINT UserExperiment_User FOREIGN KEY (user_id)
    REFERENCES "User" (id)
    ON DELETE CASCADE 
    ON UPDATE CASCADE
);

-- Table: ExperimentGuideRNA
CREATE TABLE ExperimentGuideRNA (
    id integer NOT NULL CONSTRAINT ExperimentGuideRNA_pk PRIMARY KEY,
    experiment_id integer NOT NULL,
    on_target_id integer NOT NULL,
    validated datetime NOT NULL,
    CONSTRAINT UserExperiment_Experiment FOREIGN KEY (experiment_id)
    REFERENCES Experiment (id),
    CONSTRAINT UserExperiment_OnTarget FOREIGN KEY (on_target_id)
    REFERENCES OnTarget (id)
);

-- Table: Nuclease
CREATE TABLE Nuclease (
    id integer NOT NULL CONSTRAINT Nuclease_pk PRIMARY KEY,
    name text NOT NULL,
    spacer_length integer NOT NULL DEFAULT 20,
    sense_cut_offset integer DEFAULT 4,
    antisense_cut_offset integer DEFAULT 4,
    downstream_target boolean NOT NULL DEFAULT true,
    descr text,
    CONSTRAINT NucleaseName_ak UNIQUE (name)
);

CREATE INDEX EndonucleaseVariant_idx_name
ON Nuclease (name ASC)
;

--
INSERT INTO Nuclease (id, name, sense_cut_offset, antisense_cut_offset)  VALUES ( 1, "wtCas9", 4, 4);
INSERT INTO Nuclease (id, name, sense_cut_offset, antisense_cut_offset)  VALUES ( 2, "SpCas9 Nickase", 4, NULL);
INSERT INTO Nuclease (id, name, sense_cut_offset, antisense_cut_offset)  VALUES ( 3, "SpCas9 D1135E", 4, 4);
INSERT INTO Nuclease (id, name, sense_cut_offset, antisense_cut_offset)  VALUES ( 4, "SpCas9 VRER", 4, 4);
INSERT INTO Nuclease (id, name, sense_cut_offset, antisense_cut_offset)  VALUES ( 5, "SpCas9 EQR", 4, 4);
INSERT INTO Nuclease (id, name, sense_cut_offset, antisense_cut_offset)  VALUES ( 6, "SpCas9 VQR", 4, 4);
INSERT INTO Nuclease (id, name, sense_cut_offset, antisense_cut_offset)  VALUES ( 7, "dCas9", NULL, NULL);
-- Currently Not supported 
-- INSERT INTO Nuclease (id, name, sense_cut_offset, antisense_cut_offset)  VALUES ( 8, "eSpCas9", 4, 4);
-- INSERT INTO Nuclease (id, name, sense_cut_offset, antisense_cut_offset)  VALUES ( 9, "SaCas9", 4, 4);
INSERT INTO Nuclease (id, name, sense_cut_offset, antisense_cut_offset)  VALUES (10, "NmCas9", 4, 4);
-- INSERT INTO Nuclease (id, name, sense_cut_offset, antisense_cut_offset)  VALUES (11, "StCas9", 4, 4);
INSERT INTO Nuclease (id, name, sense_cut_offset, antisense_cut_offset)  VALUES (12, "TdCas9", 4, 4);

INSERT INTO Nuclease (id, name, sense_cut_offset, antisense_cut_offset, downstream_target, descr)  VALUES (13, "FnCpf1", 18, 23, "false", "Zetsche et al.: http://www.ncbi.nlm.nih.gov/pubmed/26422227");
INSERT INTO Nuclease (id, name, sense_cut_offset, antisense_cut_offset, downstream_target, descr)  VALUES (14, "AsCpf1", 19, 23, "false", "Zetsche et al.: http://www.ncbi.nlm.nih.gov/pubmed/26422227");
INSERT INTO Nuclease (id, name, sense_cut_offset, antisense_cut_offset, downstream_target, descr)  VALUES (15, "LbCpf1", 19, 23, "false", "Zetsche et al.: http://www.ncbi.nlm.nih.gov/pubmed/26422227");;

-- Table: OffTarget
CREATE TABLE OffTarget (
    id integer NOT NULL CONSTRAINT OffTarget_pk PRIMARY KEY,
    on_target_id integer NOT NULL,
    pam_location integer NOT NULL,
    score real NOT NULL DEFAULT 0.0,
    on_sense_strand boolean NOT NULL DEFAULT true,
    at_on_target boolean NOT NULL,
    CONSTRAINT OffTarget_Target FOREIGN KEY (on_target_id)
    REFERENCES OnTarget (id)
);

CREATE INDEX OffTarget_idx_OnTarget
ON OffTarget (on_target_id ASC)
;

-- Table: OnTarget
CREATE TABLE OnTarget (
    id integer NOT NULL CONSTRAINT OnTarget_pk PRIMARY KEY,
    model_target_id integer NOT NULL,
    nuclease_id integer NOT NULL,
    pam text NOT NULL,
    pam_location integer NOT NULL DEFAULT 0,
    score real NOT NULL DEFAULT 0.0,
    spacer_length integer NOT NULL,
    seed_length integer NOT NULL,
    at_offset_position boolean NOT NULL DEFAULT false,
    on_sense_strand boolean NOT NULL DEFAULT true,
    CONSTRAINT Target_Variant FOREIGN KEY (nuclease_id)
    REFERENCES Nuclease (id),
    CONSTRAINT RnaTarget_ModelTarget FOREIGN KEY (model_target_id)
    REFERENCES DesignTarget (id)
);

-- Table: PAM
CREATE TABLE PAM (
    id integer NOT NULL CONSTRAINT PAM_pk PRIMARY KEY,
    nuclease_id integer NOT NULL,
    sequence text NOT NULL,
    survival real NOT NULL DEFAULT 0.0007,
    CONSTRAINT PAM_ak UNIQUE (sequence, nuclease_id),
    CONSTRAINT PAM_Variant FOREIGN KEY (nuclease_id)
    REFERENCES Nuclease (id)
    ON DELETE CASCADE 
    ON UPDATE CASCADE
);

-- wtCas9
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES ( 1, 1, "NGG", 0.68);
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES ( 2, 1, "NAG", 0.0132);
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES ( 3, 1, "NGA", 0.0020);
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES ( 4, 1, "NAA", 0.0007);

-- SpCas9 Nickase
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES ( 5, 2, "NGG", 0.68);
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES ( 6, 2, "NAG", 0.0132);
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES ( 7, 2, "NGA", 0.0020);
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES ( 8, 2, "NAA", 0.0007);

-- SpCas9 D1135
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES ( 9, 3, "NGG", 0.70);
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES (10, 3, "NAG", 0.002);

-- SpCas9 VRER
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES (11, 4, "NGCG", 0.70);

-- SpCas9 EQR
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES (12, 5, "NGAG", 0.70);

-- SpCas9 VQR
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES (14, 6, "NGAN", 0.70);
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES (15, 6, "NGNG", 0.70);

-- Dead dCas9
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES ( 16, 7, "NGG", 0.68);
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES ( 17, 7, "NAG", 0.0132);
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES ( 18, 7, "NGA", 0.0020);
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES ( 19, 7, "NAA", 0.0007);

-- eSpCas9
-- No any additional info
-- INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES (20, x, "XXX", x);

-- SaCas9
-- Currently Not supported 
-- INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES (21, 6, "NNGRRT", 0.70);
-- INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES (22, 6, "NNGRRN", 0.70);

-- NmCas9
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES (23, 10, "NNNNGATT", 0.70);

-- StCas9
-- Currently Not supported 
-- INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES (24, 11, "NNAGAAW", 0.70);


-- TdCas9
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES (25, 12, "NAAAAC", 0.70);


-- FnCpf1
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES (26, 13, "TTN", 0.70);
-- AsCpf1
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES (27, 14, "TTN", 0.70);
-- LbCpf1
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES (28, 15, "TTN", 0.70);;

-- Table: User
CREATE TABLE "User" (
    id integer NOT NULL CONSTRAINT User_pk PRIMARY KEY,
    login text NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    email text NOT NULL,
    CONSTRAINT User_ak UNIQUE (login)
);

PRAGMA foreign_keys=ON;;

-- End of file.

