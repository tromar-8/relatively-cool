module Layout exposing (Model(..), Msg, init, view, viewNotFound, viewAbout, update, newLayout, Info, Layout)

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
    }

type alias Info =
    { title : String
    , email : String
    }

type Item = Link String String | Text String

type Msg = BasicInfoResponse (Result Http.Error Info)
         | NavItemsResponse (Result Http.Error (List Item))
         | FooterItemsResponse (Result Http.Error (List Item))

init = (Loading, Cmd.batch
            [ basicInfo
            , footerMsg
            , navMsg
            ]
       )

basicInfo : Cmd Msg
basicInfo = Http.get { expect = Http.expectJson BasicInfoResponse decodeBasicInfo
                     , url = Util.endpoint ++ "info"
                     }

footerMsg : Cmd Msg
footerMsg = Http.get { expect = Http.expectJson NavItemsResponse (D.list decodeItem)
                     , url = Util.endpoint ++ "footer"
                     }

navMsg : Cmd Msg
navMsg = Http.get { expect = Http.expectJson FooterItemsResponse (D.list decodeItem)
                  , url = Util.endpoint ++ "nav"
                  }


decodeBasicInfo = D.map2 Info
                  (D.field "title" D.string)
                  (D.field "email" D.string)

-- Item as either Link or Text
decodeItem = D.maybe (D.field "url" D.string)
           |> D.andThen (\mUrl -> (case mUrl of
                                       Nothing -> D.map Text
                                       Just url -> D.map (Link url))
                             <| D.field "text" D.string
                        )

view model widgets =
    case model of
        Loading -> { title = "Loading..."
                   , body = [ section [ class "section columns" ]
                                  [ div [ class "column container" ]
                                        Util.loadingDiv
                                  ]
                            ]
                   }
        Got layout -> { title = layout.info.title
                      , body = [ nav [class "navbar is-primary"]
                                   [ div [class "navbar-brand"] [ a [class "navbar-item", href "/"] [text layout.info.title]]
                                   , div [class "navbar-menu"]
                                       [ div [class "navbar-start"]
                                                        [ div [ class "navbar-item" ]
                                                              (List.map viewNavItem layout.nav)
                                                        ]
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
                          Link ref str -> a [href ref, class "tag is-dark is-medium"] [ text str ]
                          Text str -> p [class "tag is-dark is-medium"] [ text str ]

viewNavItem item = case item of
                       Link ref str -> a [class "button is-dark", href ref] [text str]
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
                       funkError error = modelCase (\m -> { m | error = Just <| error :: Maybe.withDefault [] m.error})
                   in case msg of
                       BasicInfoResponse response ->
                           let funkInfo info = modelCase (\m -> { m | info = info })
                           in (Result.withDefault (funkError "Could not fetch site info")
                                   <| Result.map funkInfo response, Cmd.none)
                       NavItemsResponse response ->
                           let funkNav nav = modelCase (\m -> { m | nav = nav })
                           in (Result.withDefault (funkError "Could not fetch navbar items")
                                   <| Result.map funkNav response, Cmd.none)
                       FooterItemsResponse response ->
                           let funkFooter footer = modelCase (\m -> { m | footer = footer })
                           in (Result.withDefault (funkError "Could not fetch footer")
                                   <| Result.map funkFooter response, Cmd.none)

newLayout = Layout (Info "" "") [] [] Nothing

-- module Skeleton exposing (body)

-- import Html exposing (..)
-- import Html.Attributes exposing (..)
-- import Html.Events exposing (..)

-- body model widgets = if model.loading
--                      then [ h1 [ class "title" ] [ text "Loading"] ]
--                      else


-- module Site exposing (build, newResponse, init, viewSiteEdit, getInfo, update, Model, Msg, Response)

-- import Http
-- import Json.Decode as D
-- import Json.Encode as E
-- import Html exposing (..)
-- import Html.Attributes exposing (..)
-- import Html.Events exposing (..)

-- import Util exposing (..)

-- type Msg = InfoResponse (Result Http.Error Response)
--          | SetInfo
--          | TitleInput String
--          | AuthorInput String
--          | EmailInput String
--          | DescInput String

-- type alias Model =
--     { response : Response
--     , input : Response }

-- type alias Response =
--     { title : String
--     , author : String
--     , about : String
--     , email : String
--     }

-- build : Response -> Model
-- build r = Model r r

-- getInfo = Http.get { expect = Http.expectJson InfoResponse decodeInfo, url = endpoint ++ "info"}

-- decodeInfo : D.Decoder Response
-- decodeInfo = D.map4 Response
--              (D.field "title" D.string)
--              (D.field "author" D.string)
--              (D.field "about" D.string)
--              (D.field "email" D.string)

-- update : Msg -> Model -> (Model, Cmd Msg)
-- update msg model = let mi = model.input in
--                    case msg of
--                        InfoResponse result -> ({ model | input = Result.withDefault newResponse result }, Cmd.none)
--                        SetInfo -> (model, setInfo model.input)
--                        TitleInput title ->  ({ model | input = { mi | title = title } }, Cmd.none)
--                        AuthorInput author ->  ({ model | input = { mi | author = author } }, Cmd.none)
--                        EmailInput email ->  ({ model | input = { mi | email = email } }, Cmd.none)
--                        DescInput about ->  ({ model | input = { mi | about = about } }, Cmd.none)

-- init : (Model, Cmd Msg)
-- init = (Model newResponse newResponse, getInfo)

-- newResponse = Response "" "" "" ""
