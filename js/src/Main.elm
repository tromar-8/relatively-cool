module Main exposing (main)

import Url exposing (Url)
import Url.Parser as U
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)

import Auth
import Site
import Project
import Skeleton
import Session
import Page.Blog as Blog

type Msg
    = LinkClicked UrlRequest
    | UrlChanged Url.Url
    | AuthMsg Auth.Msg
    | SiteMsg Site.Msg
    | ProjectMsg Project.Msg
    | BlogMsg Blog.Msg

type Page
    = Project Project.Model
    | SiteEdit Site.Model
    | About
    | Blog Blog.Model
    | NotFound

type alias Model =
    { key : Nav.Key
    , page : Page
    , authModel : Auth.Model
    , site : Site.Response
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
init _ url key = ({ key = key
                  , page = NotFound
                  , authModel = Auth.newModel
                  , site = Site.newResponse
                  }
                 , Cmd.batch
                      [ Cmd.map AuthMsg Auth.checkAuth
                      , Cmd.map SiteMsg Site.getInfo
                      , Nav.pushUrl key <| Url.toString url
                      ])

view : Model -> Browser.Document Msg
view model = let widgets =
                     { navWidget = List.map (Html.map AuthMsg) <| Auth.navWidget model.authModel
                     , pageWidget = case model.page of
                                        Project pm -> Project.viewProjects pm model.authModel.auth |> Html.map ProjectMsg
                                        Blog bm -> Blog.viewBlogs bm model.authModel.auth |> Html.map BlogMsg
                                        SiteEdit siteModel -> Site.viewSiteEdit siteModel |> Html.map SiteMsg
                                        About -> div [class "columns is-centered"]
                                                 [ div [class "column is-narrow box has-text-centered"]
                                                       [ text model.site.about
                                                       , br [] [], text <| "Contact via: "
                                                       , a [href <| "mailto://" ++ model.site.email]
                                                           [text model.site.email]
                                                       ]
                                                 ]
                                        NotFound -> div [class "container has-text-centered box title"] [text "Not Found"]
                     }
             in { title = model.site.title --++ " - " ++ model.page.title
                , body = Skeleton.body model widgets
                }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
                       LinkClicked (Internal url) ->
                           case url.fragment of
                               Just "load" -> (model, Nav.load <| url.path) -- /path#load internal url full load
                               Just _ -> (model, Cmd.none)
                               Nothing -> (model, Nav.pushUrl model.key <| Url.toString url)
                       LinkClicked (External url) -> (model, Nav.load url)
                       UrlChanged url -> router url model
                       AuthMsg auth -> Auth.update auth model.authModel |> \(authModel, authMsg) -> ({ model | authModel = authModel }, Cmd.map AuthMsg authMsg)
                       SiteMsg site -> case model.page of
                                           SiteEdit sm -> Site.update site sm |> \(siteModel, siteMsg) -> ({ model | site = siteModel.input
                                                                                                           , page = SiteEdit siteModel }, Cmd.map SiteMsg siteMsg)
                                           _ -> Site.update site (Site.build model.site) |> \(siteModel, siteMsg) -> ({ model | site = siteModel.input }, Cmd.map SiteMsg siteMsg)
                       ProjectMsg project -> case model.page of
                                                 Project pm -> Project.update project pm |> \(projectModel, projectMsg) -> ({ model | page = Project projectModel }, Cmd.map ProjectMsg projectMsg)
                                                 _ -> (model, Cmd.none)
                       BlogMsg blog -> case model.page of
                                           Blog bm -> Blog.update blog bm |> \(blogModel, blogMsg) -> ({ model | page = Blog blogModel }, Cmd.map BlogMsg blogMsg)
                                           _ -> (model, Cmd.none)


router : Url -> Model -> (Model, Cmd Msg)
router url model = let --session = Session.modelToSession model
                       parser = U.oneOf <|
                                [ U.map (Project.init |> \(pm, pMsg) -> (Project pm, Cmd.map ProjectMsg pMsg)) <| U.top
                                , U.map (About, Cmd.none) <| U.s "about"
                                , U.map (Blog.init |> \(bm, bMsg) -> (Blog bm, Cmd.map BlogMsg bMsg)) <| U.s "blog"
                                ] ++ (case model.authModel.auth of
                                          Auth.Admin _ -> [ U.map (SiteEdit <| Site.build model.site, Cmd.none) <| U.s "admin"
                                                          ]
                                          _ -> []
                                     )
                       (page, msg) = Maybe.withDefault (NotFound, Cmd.none) <| U.parse parser url
                   in ({model | page = page }, msg)

subscriptions : Model -> Sub Msg
subscriptions model = Sub.none
