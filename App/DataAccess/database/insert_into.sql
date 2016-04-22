insert into Nuclease (name, origin, type, seed_length, pam_direction, cut_offset) VALUES ("Cas9", "S. pyogenes", 0, 12, 0, 4);
insert into Nuclease (name, origin, type, seed_length, pam_direction, cut_offset) VALUES ("Cas9", "S. pyogenes", 1, 12, 0, 4);

insert into PAM (nuclease_name,nuclease_origin,pam) VALUES ("Cas9","S. pyogenes","NGG");
insert into PAM (nuclease_name,nuclease_origin,pam) VALUES ("Cas9","S. pyogenes","NAG");

 
