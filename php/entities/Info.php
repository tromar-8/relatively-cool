<?php

namespace Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * @ORM\Entity
 * @ORM\Table(name="site_info")
 */
class Info
{
    /**
     * @ORM\Id
     * @ORM\Column(type="integer")
     * @ORM\GeneratedValue
     */
    protected $id;
    /**
     * @ORM\Column(type="string")
     */
    protected $title;
    /**
     * @ORM\Column(type="string")
     */
    protected $email;

    public function __construct($array) {
        setInfo($array);
    }

    public function toArray() {
        return [
            'title' => $this->title,
            'email' => $this->email
        ];
    }

    public function setInfo($array) {
        $this->title = $array['title'];
        $this->email = $array['email'];
    }
}
