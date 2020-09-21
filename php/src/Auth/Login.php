<?php

declare(strict_types=1);

namespace Auth;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Psr\Http\Server\MiddlewareInterface;
use Laminas\Diactoros\Response\RedirectResponse;
use Mezzio\Authentication\Session\PhpSession;
use Mezzio\Authentication\UserInterface;

class Login implements MiddleWareInterface
{
    protected $auth;

    public function __construct(PhpSession $auth) {
        $this->auth = $auth;
    }
    public function process(ServerRequestInterface $request, RequestHandlerInterface $handler) : ResponseInterface
    {
        $error = $request->getAttribute('error');
        $session = $request->getAttribute('session');
        $session->unset(UserInterface::class);
        if(!$error) $this->auth->authenticate($request);

        $user = $session->get(UserInterface::class);
        if(!$user && !$error) {
            $request = $request->withAttribute('error', 'Could not login.');
        }

        return $handler->handle($request);
    }
}
