-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2016-05-10 17:57:48.609

-- tables
-- Table: Experiment
CREATE TABLE Experiment (
    id integer NOT NULL,
    user_id integer NOT NULL,
    title text NOT NULL,
    date datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    validated datetime,
    descr text,
    CONSTRAINT Experiment_pk PRIMARY KEY (id),
    CONSTRAINT UserExperiment_ak UNIQUE (user_id, title, date),
    CONSTRAINT UserExperiment_User FOREIGN KEY (user_id)
    REFERENCES "User" (id)
    ON DELETE CASCADE 
    ON UPDATE CASCADE
);

-- Table: ExperimentGuideRNA
CREATE TABLE ExperimentGuideRNA (
    id integer NOT NULL,
    experiment_id integer NOT NULL,
    on_target_id integer NOT NULL,
    validated datetime NOT NULL,
    CONSTRAINT ExperimentGuideRNA_pk PRIMARY KEY (id),
    CONSTRAINT UserExperiment_Experiment FOREIGN KEY (experiment_id)
    REFERENCES Experiment (id),
    CONSTRAINT UserExperiment_OnTarget FOREIGN KEY (on_target_id)
    REFERENCES OnTarget (id)
);

-- Table: ModelOrganism
CREATE TABLE ModelOrganism (
    id integer NOT NULL,
    name text NOT NULL,
    path text,
    sequence_hash integer NOT NULL,
    descr text,
    CONSTRAINT ModelOrganism_pk PRIMARY KEY (id),
    CONSTRAINT ModelOrganism_ak UNIQUE (name)
);

-- Table: ModelTarget
CREATE TABLE ModelTarget (
    id integer NOT NULL,
    model_organism_id integer NOT NULL,
    name integer NOT NULL,
    location integer NOT NULL,
    length integer NOT NULL,
    "offset" integer NOT NULL,
    type text NOT NULL DEFAULT L,
    descr text,
    CONSTRAINT ModelTarget_pk PRIMARY KEY (id),
    CONSTRAINT ModelExperiment_ak UNIQUE (location, length, model_organism_id),
    CONSTRAINT ModelExperiment_ModelOrganism FOREIGN KEY (model_organism_id)
    REFERENCES ModelOrganism (id)
);

-- Table: Nuclease
CREATE TABLE Nuclease (
    id integer NOT NULL,
    name text NOT NULL,
    spacer_length integer NOT NULL DEFAULT 20,
    sense_cut_offset integer DEFAULT 4,
    antisense_cut_offset integer DEFAULT 4,
    downstream_target boolean NOT NULL DEFAULT true,
    descr text,
    CONSTRAINT Nuclease_pk PRIMARY KEY (id),
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
INSERT INTO Nuclease (id, name, sense_cut_offset, antisense_cut_offset)  VALUES ( 8, "eSpCas9", 4, 4);

INSERT INTO Nuclease (id, name, sense_cut_offset, antisense_cut_offset)  VALUES ( 9, "SaCas9", 4, 4);
INSERT INTO Nuclease (id, name, sense_cut_offset, antisense_cut_offset)  VALUES (10, "NmCas9", 4, 4);
INSERT INTO Nuclease (id, name, sense_cut_offset, antisense_cut_offset)  VALUES (11, "StCas9", 4, 4);
INSERT INTO Nuclease (id, name, sense_cut_offset, antisense_cut_offset)  VALUES (12, "TdCas9", 4, 4);


INSERT INTO Nuclease (id, name, sense_cut_offset, antisense_cut_offset, downstream_target, descr)  VALUES (13, "FnCpf1", 18, 23, "false", "Zetsche et al.: http://www.ncbi.nlm.nih.gov/pubmed/26422227");
INSERT INTO Nuclease (id, name, sense_cut_offset, antisense_cut_offset, downstream_target, descr)  VALUES (14, "AsCpf1", 19, 23, "false", "Zetsche et al.: http://www.ncbi.nlm.nih.gov/pubmed/26422227");
INSERT INTO Nuclease (id, name, sense_cut_offset, antisense_cut_offset, downstream_target, descr)  VALUES (15, "LbCpf1", 19, 23, "false", "Zetsche et al.: http://www.ncbi.nlm.nih.gov/pubmed/26422227");;

-- Table: OffTarget
CREATE TABLE OffTarget (
    id integer NOT NULL,
    on_target_id integer NOT NULL,
    pam_location integer NOT NULL,
    score real NOT NULL DEFAULT 0.0,
    on_sense_strand boolean NOT NULL DEFAULT true,
    at_on_target boolean NOT NULL,
    CONSTRAINT OffTarget_pk PRIMARY KEY (id),
    CONSTRAINT OffTarget_Target FOREIGN KEY (on_target_id)
    REFERENCES OnTarget (id)
);

CREATE INDEX OffTarget_idx_OnTarget
ON OffTarget (on_target_id ASC)
;

-- Table: OnTarget
CREATE TABLE OnTarget (
    id integer NOT NULL,
    model_target_id integer NOT NULL,
    nuclease_id integer NOT NULL,
    pam text NOT NULL,
    pam_location integer NOT NULL DEFAULT 0,
    score real NOT NULL DEFAULT 0.0,
    spacer_length integer NOT NULL,
    seed_length integer NOT NULL,
    at_offset_position boolean NOT NULL DEFAULT false,
    on_sense_strand boolean NOT NULL DEFAULT true,
    CONSTRAINT OnTarget_pk PRIMARY KEY (id),
    CONSTRAINT Target_Variant FOREIGN KEY (nuclease_id)
    REFERENCES Nuclease (id),
    CONSTRAINT RnaTarget_ModelTarget FOREIGN KEY (model_target_id)
    REFERENCES ModelTarget (id)
);

-- Table: PAM
CREATE TABLE PAM (
    id integer NOT NULL,
    nuclease_id integer NOT NULL,
    sequence text NOT NULL,
    survival real NOT NULL DEFAULT 0.0007,
    CONSTRAINT PAM_pk PRIMARY KEY (id),
    CONSTRAINT PAM_ak UNIQUE (sequence, nuclease_id),
    CONSTRAINT PAM_Variant FOREIGN KEY (nuclease_id)
    REFERENCES Nuclease (id)
    ON DELETE CASCADE 
    ON UPDATE CASCADE
);

INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES ( 1, 1, "NGG", 0.68);
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES ( 2, 1, "NAG", 0.0132);
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES ( 3, 1, "NGA", 0.0020);
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES ( 4, 1, "NAA", 0.0007);
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES ( 5, 2, "NGG", 0.68);
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES ( 6, 2, "NAG", 0.0132);
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES ( 7, 2, "NGA", 0.0020);
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES ( 8, 2, "NAA", 0.0007);

-- FnCpf1
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES ( 9, 13, "TTN", 0.70);
-- AsCpf1
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES (10, 14, "TTN", 0.70);
-- LbCpf1
INSERT INTO PAM (id, nuclease_id, sequence, survival)  VALUES (11, 15, "TTN", 0.70);;

-- Table: User
CREATE TABLE "User" (
    id integer NOT NULL,
    login text NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    CONSTRAINT User_pk PRIMARY KEY (id),
    CONSTRAINT User_ak UNIQUE (login)
);

PRAGMA foreign_keys=ON;;

-- End of file.

