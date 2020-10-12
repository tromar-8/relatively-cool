<?php

return [
    'mezzio-authorization-rbac' => [
        'roles' => [
            'admin' => [],
            'user' => ['admin'],
            'guest' => ['user'],
        ],
        'permissions' => [
            'guest' => [
                'denied',
                'info.get',
                'showcase.get',
                'blog.get',
                'nav.get',
                'footer.get',
                'whoami',
                'login',
                'register',
            ],
            'user' => [
                'logout',
                'blog.set',
                'blog.delete',
            ],
            'admin' => [
                'showcase.set',
                'showcase.delete',
                'info.set',
                'footer.set',
                'footer.delete',
                'nav.set',
                'nav.delete',
            ],
        ],
    ],
];
