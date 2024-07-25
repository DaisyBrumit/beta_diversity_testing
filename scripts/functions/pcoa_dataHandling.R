# THIS SCRIPT MAY OR MAY NOT BE SUPERFLUOUS
# DEPENDING ON HOW CTF/PHYLO CTF AXES ARE HANDLED
# KEEP JUST IN CASE

ctf_meta_match <- function(meta, data, study) {
  
  if (study == 'Jones') {
    
    shared.indices <- intersect(meta$repeat_ID, rownames(data))
    meta <- meta %>% filter(meta$repeat_ID %in% shared.indices)
      
  } else if (study == 'gemelli_ECAM') {
    
    shared.indices <- intersect(meta$host_subject_id_str, rownames(data))
    meta <- meta %>% filter(meta$host_subject_id_str %in% shared.indices)
  
  }
}