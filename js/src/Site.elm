module Site exposing (build, newResponse, init, viewSiteEdit, getInfo, update, Model, Msg, Response)

import Http
import Json.Decode as D
import Json.Encode as E
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Util exposing (..)

type Msg = InfoResponse (Result Http.Error Response)
         | SetInfo
         | TitleInput String
         | AuthorInput String
         | EmailInput String
         | DescInput String

type alias Model =
    { response : Response
    , input : Response }

type alias Response =
    { title : String
    , author : String
    , about : String
    , email : String
    }

build : Response -> Model
build r = Model r r

getInfo = Http.get { expect = Http.expectJson InfoResponse decodeInfo, url = endpoint ++ "info"}

setInfo input = Http.post { expect = Http.expectJson InfoResponse decodeInfo
                    , body = Http.jsonBody <| E.object
                             [ ( "title", E.string input.title )
                             , ( "author", E.string input.author )
                             , ( "about", E.string input.about )
                             , ( "email", E.string input.email )]
                    , url = endpoint ++ "info"
                    }

decodeInfo : D.Decoder Response
decodeInfo = D.map4 Response
             (D.field "title" D.string)
             (D.field "author" D.string)
             (D.field "about" D.string)
             (D.field "email" D.string)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = let mi = model.input in
                   case msg of
                       InfoResponse result -> ({ model | input = Result.withDefault newResponse result }, Cmd.none)
                       SetInfo -> (model, setInfo model.input)
                       TitleInput title ->  ({ model | input = { mi | title = title } }, Cmd.none)
                       AuthorInput author ->  ({ model | input = { mi | author = author } }, Cmd.none)
                       EmailInput email ->  ({ model | input = { mi | email = email } }, Cmd.none)
                       DescInput about ->  ({ model | input = { mi | about = about } }, Cmd.none)

init : (Model, Cmd Msg)
init = (Model newResponse newResponse, getInfo)

newResponse = Response "Loading" "" "" ""

viewSiteEdit model = Html.form [class "container box", onSubmit SetInfo]
                             [ div [class "field"]
                                   [ label [class "label"] [text "Site Title:"]
                                   , div [class "control"] [ input [ class "input"
                                                                   , type_ "text"
                                                                   , placeholder "title"
                                                                   , onInput TitleInput
                                                                   , value model.input.title
                                                                   ] []
                                                           ]
                                   ]
                             , div [class "field"]
                                   [ label [class "label"] [text "Site Author:"]
                                   , div [class "control"] [ input [ class "input"
                                                                   , type_ "text"
                                                                   , placeholder "author"
                                                                   , onInput AuthorInput
                                                                   , value model.input.author
                                                                   ] []
                                                           ]
                                   ]
                             , div [class "field"]
                                   [ label [class "label"] [text "Site Email:"]
                                   , div [class "control"] [ input [ class "input"
                                                                   , type_ "text"
                                                                   , placeholder "email"
                                                                   , onInput EmailInput
                                                                   , value model.input.email
                                                                   ] []
                                                           ]
                                   ]
                             , div [class "field"]
                                   [ label [class "label"] [text "Site Description:"]
                                   , div [class "control"] [ input [ class "input"
                                                                   , type_ "text"
                                                                   , placeholder "description"
                                                                   , onInput DescInput
                                                                   , value model.input.about
                                                                   ] []
                                                           ]
                                   ]
                             , button [class "button is-primary"] [text "Update"]
                             ]
