<?php

declare(strict_types=1);

namespace Auth;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Mezzio\Authentication\UserInterface;
use Mezzio\Authentication\DefaultUser;

class NewGuest implements MiddlewareInterface
{
    public function process(ServerRequestInterface $request, RequestHandlerInterface $handler) : ResponseInterface
    {
        $session = $request->getAttribute('session');
        $user = $session->get(UserInterface::class);
        if(!$user) {
            $session->set(UserInterface::class, [
                'username' => 'guest',
                'roles'    => ['guest'],
                'details'  => []
            ]);
        }

        return $handler->handle($request);
    }
}
