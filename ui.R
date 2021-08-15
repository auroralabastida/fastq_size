library(shiny)
library(here)
library(fs)
library(dplyr)
library(shinythemes)
source(path(here(),"R","fastq_size_functions.R"))

platform_specs<-read.csv(path(here(),"www","Seq_platform_specs.csv"))
platform_list<-platform_list(platform_specs)
platform<-platform_list[1]
chemistries<-chemistry_list(platform_specs, platform)
chemistry<-chemistries[1]
seq_lens<-chemistry_chars(platform_specs, platform, chemistry)[[2]]

shinyUI(fluidPage(
    titlePanel(h2("Size of FASTQ files",style="text-align:center")),
    theme = shinytheme("cerulean"),

    br(),

    sidebarLayout(
    sidebarPanel(

    radioButtons("How_to", p(h4("How will we estimate?")),
                 c("By sequence properties","By sequencing platform")
                 , selected = "By sequence properties"),

    conditionalPanel(
    condition="input.How_to == 'By sequencing platform'",

    selectInput("seq_platform",
                label="Choose a sequencing platform",
                choices=platform_list,selected=platform),

    selectInput("platform_chem",
                label="Chemistries for this platform",
                choices=chemistries, selected = chemistry),

    selectInput("length",
                label="Available read lengths",
                choices=seq_lens)
    ),
    conditionalPanel(

        condition="input.How_to == 'By sequence properties'",

        numericInput("seq_len", value=100,
                 label=p("Sequence length")),
        numericInput("total_reads", value=2000000,
                 label=p("Total number of sequences")),
        numericInput("seq_id_len", value=66,
                 label=p("Sequence identifier length"))
        )
    ),
    mainPanel(
        tags$img(src="fastq_format.png",height="140px"),
        column(12, align="center",
        tableOutput("size_table"),
        br(),
        textOutput("table_legend")
        )
    )
),
hr(),
p("Developed by Aurora Labastida M. This application is open source under AGPL-3.0 licence.",style="text-align:center; font-family: times")))
