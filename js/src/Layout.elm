module Layout exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as D
import Json.Encode as E
import Browser.Navigation as Nav

import Util

type Model = Loading
           | Got Layout

type alias Layout =
    { info : Info
    , nav : List Item
    , footer : List Item
    , error : Maybe (List String)
    , nightMode : Bool
    , toggleNav : Bool
    }

type alias Info =
    { title : String
    , email : String
    }

type Item = Link String String | Text String

type Msg = BasicInfoResponse (Result Http.Error Info)
         | NavItemsResponse (Result Http.Error (List Item))
         | FooterItemsResponse (Result Http.Error (List Item))
         | ToggleNav

init = (Loading, Cmd.batch
            [ basicInfo
            , footerMsg
            , navMsg
            ]
       )

basicInfo : Cmd Msg
basicInfo = Http.get { expect = Http.expectJson BasicInfoResponse decodeInfo
                     , url = Util.endpoint ++ "info"
                     }

footerMsg : Cmd Msg
footerMsg = Http.get { expect = Http.expectJson NavItemsResponse (D.list decodeItem)
                     , url = Util.endpoint ++ "nav"
                     }

navMsg : Cmd Msg
navMsg = Http.get { expect = Http.expectJson FooterItemsResponse (D.list decodeItem)
                  , url = Util.endpoint ++ "footer"
                  }


decodeInfo = D.map2 Info
                  (D.field "title" D.string)
                  (D.field "email" D.string)

-- Item as either Link or Text
decodeItem = D.maybe (D.field "url" D.string)
           |> D.andThen (\mUrl -> (case mUrl of
                                       Nothing -> D.map Text
                                       Just url -> D.map (Link url))
                             <| D.field "text" D.string
                        )

encodeItem i = case i of
                   Link url text -> E.object [ ( "text", E.string text )
                                             , ( "url", E.string url )
                                             ]
                   Text text -> E.object [ ( "text", E.string text ) ]


view msgWrap model widgets =
    case model of
        Loading -> { title = "Loading..."
                   , body = [ section [ class "section columns" ]
                                  [ div [ class "column is-narrow container" ]
                                        Util.loadingDiv
                                  ]
                            ]
                   }
        Got layout -> { title = layout.info.title
                      , body = [ nav [class "navbar is-primary"]
                                   [ div [class "navbar-brand"]
                                         [ a [class "navbar-item", href "/"] [text layout.info.title]
                                         , a [ property "role" <| E.string "button"
                                             , class <| ( if layout.toggleNav then "is-active" else "" )++" navbar-burger"
                                             , property "data-target" <| E.string "navMenu"
                                             , href "#"
                                             , Html.Attributes.map msgWrap <| onClick ToggleNav
                                             ]
                                               [ span [] []
                                               , span [] []
                                               , span [] []
                                               ]
                                         ]
                                   , div [ class <| ( if layout.toggleNav then "is-active" else "" )++" navbar-menu"
                                         , id "navMenu"]
                                       [ div [class "navbar-start"]
                                             (List.map viewNavItem layout.nav)
                                       , div [class "navbar-end"] widgets.authWidget
                                       ]
                                   ]
                             , section [class "section"] [widgets.pageWidget]
                             , footer [class "footer has-text-centered"]
                                 [ div []
                                       (List.map viewFooterItem layout.footer)
                                 ]
                             ]
                    }

viewFooterItem item = case item of
                          Link ref str -> a [href ref] [ text str ]
                          Text str -> p [] [ text str ]

viewNavItem item = case item of
                       Link ref str -> a [href ref, class "navbar-item"] [text str]
                       Text str -> div [] [text str]

viewAbout model = section [class "section columns"]
                  [ div [class "column container"]
                        [ h1 [class "title has-text-centered"] [text "About"]
                        ]
                  ]

viewNotFound model = div [] [ text "not found" ]

update msg model = let modelCase function = case model of
                                       Got layout -> Got <| function layout
                                       Loading -> Got <| function newLayout
                       withError error = modelCase (\m -> { m | error = Just <| error :: Maybe.withDefault [] m.error})
                   in case msg of
                       BasicInfoResponse response ->
                           let withInfo info = modelCase (\m -> { m | info = info })
                           in (Result.withDefault (withError "Could not fetch site info")
                                   <| Result.map withInfo response, Cmd.none)
                       NavItemsResponse response ->
                           let withNav nav = modelCase (\m -> { m | nav = nav })
                           in (Result.withDefault (withError "Could not fetch navbar items")
                                   <| Result.map withNav response, Cmd.none)
                       FooterItemsResponse response ->
                           let withFooter footer = modelCase (\m -> { m | footer = footer })
                           in (Result.withDefault (withError "Could not fetch footer")
                                   <| Result.map withFooter response, Cmd.none)
                       ToggleNav -> ( modelCase (\m -> { m | toggleNav = not m.toggleNav }), Cmd.none )

newLayout = Layout (Info "" "") [] [] Nothing False False
newItem = Link "" ""
