module Main exposing (main)

import Url exposing (Url)
import Url.Parser as U
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)

import Auth
import Layout
import Page.ShowCase as ShowCase
import Page.Blog as Blog
import Page.Settings as Settings

type Msg
    = LinkClicked UrlRequest
    | UrlChanged Url.Url
    | AuthMsg Auth.Msg
    | LayoutMsg Layout.Msg
    | ShowCaseMsg ShowCase.Msg
    | BlogMsg Blog.Msg
    | SettingsMsg Settings.Msg

type Page
    = ShowCase ShowCase.Model
    | Blog Blog.Model
    | Settings Settings.Model
    | About
    | NotFound

type alias Model = { key : Nav.Key
                   , page : Page
                   , auth : Auth.Model
                   , layout : Layout.Model
                   }

main : Program () Model Msg
main = Browser.application
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    , onUrlRequest = LinkClicked
    , onUrlChange = UrlChanged
    }

init : () -> Url -> Nav.Key -> (Model, Cmd Msg)
init _ url key = let (layoutModel, layoutMsg) = Layout.init
                     (authModel, authMsg) = Auth.init
                 in ({ key = key
                     , page = NotFound
                     , auth = authModel
                     , layout = layoutModel
                     }
                    , Cmd.batch
                         [ Cmd.map AuthMsg authMsg
                         , Cmd.map LayoutMsg layoutMsg
                         , Nav.pushUrl key <| Url.toString url
                         ]
                    )

view : Model -> Browser.Document Msg
view model = let widgets = -- TODO change model.auth.auth to a session structure
                     { authWidget = Auth.navWidget model.auth |> List.map (Html.map AuthMsg)
                     , pageWidget = case model.page of
                                        ShowCase subModel -> ShowCase.view subModel model.auth |> Html.map ShowCaseMsg
                                        Blog subModel -> Blog.view subModel model.auth |> Html.map BlogMsg
                                        Settings subModel -> Settings.view subModel model.auth |> Html.map SettingsMsg
                                        About -> Layout.viewAbout model
                                        NotFound -> Layout.viewNotFound model
                     }
             in Layout.view LayoutMsg model.layout widgets

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = let updater wrapModel wrapMsg (subModel, subMsg) = (wrapModel subModel, Cmd.map wrapMsg subMsg)
                   in case msg of
                       LinkClicked (Internal url) ->
                           case url.fragment of
                               Just "load" -> (model, Nav.load <| url.path) -- /path#load internal url full load
                               Just _ -> (model, Cmd.none)
                               Nothing -> (model, Nav.pushUrl model.key <| Url.toString url)
                       LinkClicked (External url) -> (model, Nav.load url)
                       UrlChanged url -> router url model
                       AuthMsg subMsg -> Auth.update subMsg model.auth
                                      |> updater (\newModel -> { model | auth = newModel}) AuthMsg
                       LayoutMsg subMsg -> Layout.update subMsg model.layout
                                        |> updater (\newModel -> { model | layout = newModel}) LayoutMsg
                       ShowCaseMsg subMsg ->
                           case model.page of
                               ShowCase subModel -> ShowCase.update subMsg subModel
                                          |> updater (\newModel -> { model | page = ShowCase newModel}) ShowCaseMsg
                               _ -> (model, Cmd.none)
                       BlogMsg subMsg ->
                           case model.page of
                               Blog subModel -> Blog.update subMsg subModel
                                      |> updater (\newModel -> { model | page = Blog newModel}) BlogMsg
                               _ -> (model, Cmd.none)
                       SettingsMsg subMsg ->
                           case model.page of
                               Settings subModel -> Settings.update subMsg subModel
                                      |> updater (\newModel -> { model | page = Settings newModel}) SettingsMsg
                               _ -> (model, Cmd.none)


router : Url -> Model -> (Model, Cmd Msg)
router url model = let --session = Session.modelToSession model
                       parser = U.oneOf <|
                                [ U.map (ShowCase.init |> \(subModel, subMsg) -> (ShowCase subModel, Cmd.map ShowCaseMsg subMsg)) <| U.top
                                , U.map (About, Cmd.none) <| U.s "about"
                                , U.map (Blog.init |> \(subModel, subMsg) -> (Blog subModel, Cmd.map BlogMsg subMsg)) <| U.s "blog"
                                , U.map (Settings.init model.auth |> \(subModel, subMsg) -> (Settings subModel, Cmd.map SettingsMsg subMsg)) <| U.s "settings"
                                ]
                       (page, msg) = Maybe.withDefault (NotFound, Cmd.none) <| U.parse parser url
                   in ({model | page = page }, msg)

subscriptions : Model -> Sub Msg
subscriptions model = Sub.none
