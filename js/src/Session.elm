module Session exposing (..) --(modelToSession)

import Browser.Navigation as Nav

-- If Auth is a guest, session will hold extra data for input fields and http errors
--type AuthSession = Result (Auth.Session Auth.Auth)

type alias Session =
    { key : Nav.Key
--    , auth : Auth.Auth
    }
