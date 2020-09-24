module Skeleton exposing (body)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

body model widgets = if model.loading
                     then [ h1 [ class "title" ] [ text "Loading"] ]
                     else [ nav [class "navbar is-primary"]
                                [ div [class "navbar-brand"] [ a [class "navbar-item", href "/"] [text model.site.title]]
                                , div [class "navbar-menu"]
                                    [ div [class "navbar-start"]
                                          [ div [ class "navbar-item" ]
                                                [ a [class "tag is-medium is-dark", href "/blog"] [text "Blog" ]
                                                ]
                                          ]
                                    , div [class "navbar-end"] widgets.navWidget
                                    ]
                                ]
                          , section [class "section"] [widgets.pageWidget]
                          , footer [class "footer has-text-centered"]
                              [ div [ class "tag is-primary is-large" ]
                                    [ a [href "/about", class "tag is-dark is-medium"]
                                          [text model.site.author]
                                    , p [class "tag is-primary"] [text " | "]
                                    , p [class "tag is-dark is-medium"] [ text "2020"]
                                    ]
                              ]
                          ]
