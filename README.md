# MetAPI ISBN

MetAPI ISBN est une API regroupant plusieurs sources de données liées aux ISBN de livres. L'objectif de cette API est de fournir des informations détaillées sur un livre à partir de son ISBN, en agrégeant les données provenant de différentes sources.

## Fonctionnalités

-   Recherche d'informations sur un livre à partir de son ISBN.
-   Agrégation des informations provenant de différentes API liées aux ISBN.
-   Sélection des meilleures informations disponibles en fonction des sources de données.
-   Possibilité de récupérer toutes les informations brutes disponibles.

## Sources de données

MetAPI ISBN intègre les sources de données suivantes :

-   Google Books API : Fournit des informations sur les livres à partir de l'API Google Books.
-   Bibliothèque nationale de France (BNF) : Permet d'obtenir des données bibliographiques à partir du catalogue de la BNF.
-   Open Library API : Donne accès à une vaste collection de données sur les livres via l'API Open Library.

## Utilisation

Pour utiliser MetAPI ISBN, vous devez effectuer une requête HTTP GET avec l'ISBN du livre souhaité comme paramètre. L'API renverra les informations disponibles sur le livre dans un format JSON.

Exemple de requête :

```         
GET /api/isbn/{ISBN}
```

Exemple de réponse :

``` json
{
  "isbn": "9781234567890",
  "title": "Titre du livre",
  "author": "Auteur du livre",
  "publicationDate": "2022-01-01",
  "description": "Description du livre",
  "pageCount": 300,
  "language": "Français",
  "publisher": "Éditeur du livre",
  "series": "Série du livre",
  "volume": 2,
  "format": "Broché",
  "coverUrl": "https://example.com/book_cover.jpg"
}
```

## Configuration

Avant d'utiliser MetAPI ISBN, vous devez vous assurer d'avoir les clés d'accès nécessaires aux différentes API intégrées. Vous devrez fournir ces clés d'accès dans le fichier de configuration de l'API.

## Contributions

Les contributions à MetAPI ISBN sont les bienvenues ! Si vous souhaitez apporter des améliorations, corriger des bugs ou ajouter de nouvelles fonctionnalités, n'hésitez pas à soumettre une demande de pull.

## Licence

MetAPI ISBN est distribué sous la licence MIT. Veuillez consulter le fichier `LICENSE` pour plus d'informations.
