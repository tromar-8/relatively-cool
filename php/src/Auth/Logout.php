<?php

declare(strict_types=1);

namespace Auth;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Mezzio\Authentication\UserInterface;
use Laminas\Diactoros\Response\RedirectResponse;

class Logout implements RequestHandlerInterface
{
    public function handle(ServerRequestInterface $request) : ResponseInterface
    {
        $request->getAttribute('session')->unset(UserInterface::class);
        return new RedirectResponse("whoami");
    }
}
