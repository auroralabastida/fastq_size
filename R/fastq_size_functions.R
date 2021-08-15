##Please refer to the Illumina FASTQ format description:
##https://support.illumina.com/bulletins/2016/04/fastq-files-explained.html


#Estimate byte size of each sequence
seq_Byte_size<-function(seq_id_len,seq_len){

  separator_length<-1 #separator line length
  new_line_chars<-4 #new line characters per sequence

  seq_Byte_size<- seq_id_len + #sequence id line length
    (seq_len*2) + #length of the sequence/read
    separator_length +
    new_line_chars

  return(seq_Byte_size)
}

#Estimate file size from read length, seq_id_size an number of reads
#Create data frame of un uncompressed and compressed file sizes
#FASTQ file compression with gzip
#reduces the file size aprox. 3.58 times.
#See: http://www.softpanorama.org/HPC/DNA_sequencing/index.shtml

file_size_table<-function(seq_id_len, seq_len, total_reads){

  seq_Byte_size<-seq_Byte_size(seq_id_len,seq_len)

  file_Byte_size<-seq_Byte_size*total_reads
  file_Kylobyte_size<-file_Byte_size/1024
  file_Megabyte_size<-file_Kylobyte_size/1024
  file_Gigabyte_size<-file_Megabyte_size/1024
  file_Terabyte_size<-file_Gigabyte_size/1024


  uncomp_sizes<-c(file_Byte_size, file_Kylobyte_size,
                file_Megabyte_size,file_Gigabyte_size)

  gzcomp_sizes<-uncomp_sizes/3.58

  uncomp_gzcomp<-cbind(
    uncompressed=uncomp_sizes,
    gz_compressed=gzcomp_sizes)

  rownames(uncomp_gzcomp)<-c("Bytes","Kilobytes","Megabytes","Gigabytes")
  colnames(uncomp_gzcomp)<-c("Uncompressed FASTQ","Gzip compressed")

  return(uncomp_gzcomp)
}

platform_list<-function(platform_specs_df)
{
  return(unique(sort(platform_specs_df$Platform)))
}


chemistry_list<-function(platform_specs_df, seq_platform)
{
  platform_specs_df<-platform_specs_df %>% filter(Platform==seq_platform)
  return(unique(sort(platform_specs_df$Chemistry_details)))
}


chemistry_chars<-function(platform_specs_df, ngs_platform, platform_chemistry)
{
  platform_specs_df<-platform_specs_df %>% mutate(
        Sequence_format = ifelse(
        Sequence_format == "paired end", 2, 1) ) %>% mutate(
          max_fragments=max_reads/Sequence_format )

  platform_specs_df<-platform_specs_df %>%
    filter( Platform==ngs_platform &
      Chemistry_details==platform_chemistry )

  max_fragments<-unique(platform_specs_df$max_fragments)
  seq_lens<-unique(platform_specs_df$Read_Length)

  return(list(max_fragments,seq_lens))
}
