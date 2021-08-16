library(shiny)
library(here)
library(fs)
source(path(here(),"R","fastq_size_functions.R"))

platform_specs<-read.csv(path(
  here(),"www","Seq_platform_specs.csv"))

shinyServer(function(input, output, session) {


  observe({ choices<-chemistry_list( platform_specs, input$seq_platform)
            updateSelectInput( session,
                              inputId="platform_chem",
                              choices= choices,
                              selected=choices[1])  })


  observe({ updateSelectInput( session,
                              inputId="length",
                              choices= chemistry_chars(
                                platform_specs,
                                input$seq_platform,
                                input$platform_chem)[[2]] )  })


  max_frags_lens<-reactive({
    chemistry_chars(
      platform_specs, input$seq_platform, input$platform_chem )
      })

  output$size_table<-renderTable({

    if(input$How_to == 'By sequence properties'){
      file_size_table(input$seq_id_len,
                      input$seq_len,
                      input$total_reads)
    }
    else{
      req(max_frags_lens()[[1]], input$length)
      file_size_table(66,
                      as.numeric(input$length),
                      as.numeric(max_frags_lens()[[1]])) #El error viene de esta línea
    }},digits=1,rownames = TRUE)



  output$table_legend<-renderText({

      if(input$How_to == 'By sequence properties'){
      sprintf("Size of a single FASTQ file with %s reads of %s bp
             and identifiers of %s characters. When using a paired-end mode sequencing (for example
             2 x %s), two files with the same characteristics will be generated (for the forward and reverse reads).",
             as.character(input$total_reads), as.character(input$seq_len),
             as.character(input$seq_id_len), as.character(input$seq_len))
      }
      else{
      sprintf("Maximum size of the FASTQ files produced in a single-end sequencing run of
              the %s platform, generating %s reads of length %s. Please notice that
              the file size will duplicate for the paired-end mode, which would
              generate %s reads. The single and/or paired end modes can be available
              for a given platform and chemistry combination.",
      input$seq_platform, as.character(max_frags_lens()[[1]]),
      as.character(input$length), as.character(max_frags_lens()[[1]]*2))
     }
  })

})




