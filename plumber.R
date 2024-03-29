
library(plumber)
library(httr)
library(jsonlite)
library(xml2)

#* @apiTitle ISBN_MetAPI

####### Google books Function #######

gbooks_API <- function(isbn = "") {
  gbooks <- GET(paste0("https://www.googleapis.com/books/v1/volumes?q=+isbn:", isbn))
  gbooks <- jsonlite::fromJSON(content(gbooks, "text"), simplifyVector = FALSE)

  return(gbooks)
}

gbooks_parse <- function(dollar) {
  if (is.null(eval(parse(text = paste0("gbooks$items[[1]]$", dollar))))) {
    return(NA)
  } else {
    return(eval(parse(text = paste0("gbooks$items[[1]]$", dollar))))
  }
}


####### BNF Function #######

bnf_API <- function(isbn = "") {
  bnf <- xml2::read_xml(GET(
    paste0(
      "https://catalogue.bnf.fr/api/SRU?version=1.2&operation=searchRetrieve&query=bib.isbn%20adj%20%22",
      isbn, "%22&recordSchema=intermarcXchange"
    )
  ))
  return(bnf)
}

xml_parse <- function(tag, code) {
  if (identical(xml_text(xml_find_all(bnf, paste0(
    ".//mxc:datafield[@tag='", tag,
    "']/mxc:subfield[@code='", code, "']"
  ))), character(0))) {
    return(NA)
  } else {
    if (tag == "290" && code == "v" && !identical(xml_text(xml_find_all(bnf, paste0(
      ".//mxc:datafield[@tag='", "460",
      "']/mxc:subfield[@code='", "v", "']"
    ))), character(0))) {
      return(xml_text(xml_find_all(bnf, paste0(
        ".//mxc:datafield[@tag='", "460",
        "']/mxc:subfield[@code='", "v", "']"
      ))))
    } else {
      return(xml_text(xml_find_all(bnf, paste0(
        ".//mxc:datafield[@tag='", tag,
        "']/mxc:subfield[@code='", code, "']"
      ))))
    }
  }
}


####### Open Library Function #######

ol_API <- function(isbn = "") {
  OL <- GET(paste0("https://openlibrary.org/isbn/", isbn, ".json"))
  if (status_code(OL) == 200) {
    OL <- jsonlite::fromJSON(content(OL, "text", encoding = "UTF-8"), simplifyVector = FALSE)
  }
  return(OL)
}

OL_parse <- function(dollar) {
  if (length(dollar) == 1) {
    if (is.null(eval(parse(text = paste0("OL$", dollar))))) {
      return(NA)
    } else {
      return(eval(parse(text = paste0("OL$", dollar))))
    }
  } else if (length(dollar) == 2) {
    if (!is.null(eval(parse(text = paste0("OL$", dollar[2]))))) {
      return(eval(parse(text = paste0("OL$", dollar[2]))))
    } else if (!is.null(eval(parse(text = paste0("OL$", dollar[1]))))) {
      return(eval(parse(text = paste0("OL$", dollar[1]))))
    } else {
      return(NA)
    }
  } else {
    return(eval(parse(text = paste0("OL$", dollar))))
  }
}

OL_author <- function(ol_author_key) {
  if (is.null(OL$authors[[1]]$key)) {
    return(NA)
  } else {
    OL_aut <- GET(paste0("https://openlibrary.org", ol_author_key, ".json"))
    OL_aut <- jsonlite::fromJSON(content(OL_aut, "text", encoding = "UTF-8"), simplifyVector = FALSE)
    if (!is.null(OL_aut$personal_name)) {
      return(OL_aut$personal_name)
    } else if (!is.null(OL_aut$name)) {
      return(OL_aut$name)
    } else {
      return(NA)
    }
  }
}



####### Main Function #######

#* Echo back the metadata of the input ISBN
#* @param isbn The ISBN you want to obtain the metadata
#* @get /isbn
function(isbn = "", all = T) {


  ####### Variable Test #######
  # isbn = c("9782013229036" ,  "9782081288539" ,  "9782203035362")
  # isbn = "2277124532"
  # isbn <- "9782203035362"
  isbn = "9782747033343"

  ####### Variable Global #######

  df_final <- data.frame(matrix(nrow = 12, ncol = 0))
  rownames(df_final) <- c(
    "ISBN", "Titre", "Auteur", "Date de Publication",
    "Description", "Nb de Pages", "Langues",
    "Editeur", "Serie", "Tome", "Format", "URL Couv"
  )

  df <- data.frame(matrix(nrow = 12, ncol = 4))
  rownames(df) <- c(
    "ISBN", "Titre", "Auteur", "Date de Publication",
    "Description", "Nb de Pages", "Langues",
    "Editeur", "Serie", "Tome", "Format", "URL Couv"
  )
  colnames(df) <- c("Google Books", "BNF", "OpenLibrary", "Final")





  ####### Google Books API #######

  gbooks <- gbooks_API(isbn)

  df[1, 1] <- isbn
  df[2, 1] <- gbooks_parse("volumeInfo$title")
  df[3, 1] <- gbooks_parse("volumeInfo$authors[[1]]")
  df[4, 1] <- gbooks_parse("volumeInfo$publishedDate")
  df[5, 1] <- gbooks_parse("volumeInfo$description")
  df[6, 1] <- gbooks_parse("volumeInfo$pageCount")
  df[7, 1] <- gbooks_parse("volumeInfo$language")



  ####### BNF #######

  bnf <- bnf_API(isbn)

  if (!is.na(xml_parse(tag = "245", code = "a"))) {
    df[1, 2] <- isbn
    df[2, 2] <- xml_parse("245", "a")
    df[3, 2] <- xml_parse("245", "f")
    df[4, 2] <- substr(xml_parse("044", "c"), 2, nchar(xml_parse("044", "c")))
    df[5, 2] <- xml_parse("830", "a")
    # df[6,2] = xml_parse("280" , "a")
    df[7, 2] <- xml_parse("041", "a")
    df[8, 2] <- if (length(xml_parse("260", "c")) > 1) {
      paste(xml_parse("260", "c")[1], ",", xml_parse("260", "c")[2])
    } else {
      xml_parse("260", "c")
    }
    df[9, 2] <- xml_parse("290", "a")
    df[10, 2] <- xml_parse("290", "v")
    # df[11,2] = xml_parse("280" , "d")
  }


  ####### Open Library #######

  OL <- ol_API(isbn)

  df[1, 3] <- isbn
  df[2, 3] <- OL_parse(c("full_title", "title"))
  df[3, 3] <- OL_author(OL$authors[[1]]$key)
  df[4, 3] <- OL_parse("publish_date")
  df[5, 3] <- OL_parse(c("description$value", "description"))
  df[6, 3] <- OL_parse("number_of_pages")
  df[7, 3] <- OL_parse("languages[[1]]$key")
  df[8, 3] <- OL_parse("publishers")
  df[9, 3] <- NA
  df[10, 3] <- NA
  df[11, 3] <- NA



  couv_OL <- GET(paste0("https://covers.openlibrary.org/b/isbn/", isbn, "-M.jpg"))
  if (status_code(couv_OL) == 200 && !is.null(couv_OL$headers$`content-type`) && couv_OL$headers$`content-type` == "image/jpeg") {
    df[12, 3] <- paste0("https://covers.openlibrary.org/b/isbn/", isbn, "-M.jpg")
  }

  ####### Final #######

  df[1, "Final"] <- isbn

  ## Titre
  if (!is.na(df[2, 2])) {
    df[2, "Final"] <- df[2, 2]
  } else if (!is.na(df[2, 1])) {
    df[2, "Final"] <- df[2, 1]
  } else if (!is.na(df[2, 3])) {
    df[2, "Final"] <- df[2, 3]
  }

  ## Auteur
  if (!is.na(df[3, 2])) {
    df[3, "Final"] <- df[3, 2]
  } else if (!is.na(df[3, 1])) {
    df[3, "Final"] <- df[3, 1]
  } else if (!is.na(df[3, 3])) {
    df[3, "Final"] <- df[3, 3]
  } else {
    df[3, "Final"] <- "None"
  }

  ## Date
  if (!is.na(df[4, 1])) {
    df[4, "Final"] <- df[4, 1]
  } else if (!is.na(df[4, 2])) {
    df[4, "Final"] <- df[4, 2]
  } else if (!is.na(df[4, 3])) {
    df[4, "Final"] <- df[4, 3]
  } else {
    df[4, "Final"] <- "1000"
  }

  ## Desc
  if (!is.na(df[5, 1])) {
    df[5, "Final"] <- strtrim(df[5, 1], 1999)
  } else if (!is.na(df[5, 2])) {
    df[5, "Final"] <- strtrim(df[5, 2], 1999)
  }

  ## Nb de page
  if (!is.na(df[6, 1])) {
    df[6, "Final"] <- df[6, 1]
  } else if (!is.na(df[6, 3])) {
    df[6, "Final"] <- df[6, 3]
  }

  ## Langues
  if (!is.na(df[7, 1])) {
    df[7, "Final"] <- df[7, 1]
  } else if (!is.na(df[7, 3])) {
    df[7, "Final"] <- df[7, 3]
  }


  ## Editeur
  if (!is.na(df[8, 2])) {
    df[8, "Final"] <- df[8, 2]
  } else if (!is.na(df[8, 3])) {
    df[8, "Final"] <- df[8, 3]
  } else {
    df[8, "Final"] <- "None"
  }

  ## Série
  if (!is.na(df[9, 2])) {
    df[9, "Final"] <- strsplit(df[9, 2], ",")[[1]][1]
  }

  ## Tome
  if (!is.na(df[10, 2])) {
    df[10, "Final"] <- gsub(",", ".", df[10, 2])
  }

  ## Format
  df[11, "Final"] <- df[11, 2]

  ## URL Couv
  df[12, "Final"] <- df[12, 3]



  ####### Print #######

  if (all) {
    liste_final <- list()
    for (i in colnames(df)) {
      liste_final[[i]] <- as.list(df[, i])
      names(liste_final[[i]]) <- rownames(df)
    }
    liste_final
  } else {
    df_final <- df[, "Final"]
    df_final <- t(df_final)
    colnames(df_final) <- rownames(df)
    rownames(df_final) <- df_final[, 1]
    df_final[is.na(df_final)] <- " "
    df_final <- as.data.frame(df_final)
    df_final
  }
}
