<?php

return [
    'mezzio-authorization-rbac' => [
        'roles' => [
            'admin' => [],
            'user'        => ['admin'],
            'guest'   => ['user'],
        ],
        'permissions' => [
            'guest' => [
                'denied',
                'info.get',
                'project.get',
                'whoami',
                'login',
                'register',
                'blog.get',
            ],
            'user' => [
                'logout',
                'blog.set',
            ],
            'admin' => [
                'info.set',
                'project.set',
                'project.delete',
                'blog.delete',
            ],
        ],
    ]
];
