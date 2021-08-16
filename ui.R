library(shiny)
library(here)
library(fs)
library(dplyr)
source(path(here(),"R","fastq_size_functions.R"))

platform_specs<-read.csv(path(here(),"www","Seq_platform_specs.csv"))
platform_list<-platform_list(platform_specs)
platform<-platform_list[1]
chemistries<-chemistry_list(platform_specs, platform)
chemistry<-chemistries[1]
seq_lens<-chemistry_chars(platform_specs, platform, chemistry)[[2]]

shinyUI(fluidPage(

    HTML('<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,400;0,700;1,400;1,700&display=swap" rel="stylesheet">'),

    theme="style.css",

    div(class="ocean",
        titlePanel(h1("FASTQ Size")),
        h2("For different sequence properties and NGS platforms")
    ),

    br(),br(), br(),

    div(class="mainstyle",
    sidebarLayout(
    sidebarPanel(

        radioButtons("How_to", p(h3("How will we estimate?")),
                 c("By sequence properties","By sequencing platform")
                 , selected = "By sequence properties"),
        br(),
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
        column(12, align="center",

            tags$img(src="fastq_format_2.png",width="80%"),
            br(),br(),br(),br(),
            tableOutput("size_table"),
            br(),
            div(class="legend", textOutput("table_legend"))

        )
    )
),
),

    br(),br(),br(),br(),
    div( class="devmessage",
        br(),
        p("Developed by Aurora Labastida"),
        HTML('<a href="https://github.com/auroralabastida/"><img src="github.png" title="GitHub account" height="60" /></a>'),
        HTML('<a href="https://www.linkedin.com/in/aurora-labastida-mart%C3%ADnez/"><img src="linkedin.png" title="LinkedIn account" height="60" /></a>'),
        p("Open source under AGPL-3.0 licence.")
    ),
))
