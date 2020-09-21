<?php

declare(strict_types=1);

namespace Auth;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Mezzio\Authentication\UserRepositoryInterface;
use Mezzio\Authentication\UserInterface;
use Mezzio\Authentication\DefaultUser;
use Laminas\Diactoros\Response\JsonResponse;
use Doctrine\ORM\EntityManager;

class OrmAccess implements UserRepositoryInterface
{
    protected $orm;

    public function __construct(EntityManager $orm) {
        $this->orm = $orm;
    }

    public function authenticate(string $credential, string $password = null) : ?UserInterface {
        $user = $this->orm->getRepository('Entity\User')->findOneBy(['name' => $credential]);

        if($user && password_verify($password, $user->getPassword())) {
            return new DefaultUser($credential, [$user->getAdmin() ? 'admin' : 'user'], []);
        }

        return null;
    }
}
