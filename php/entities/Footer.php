<?php

namespace Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * @ORM\Entity
 * @ORM\Table(name="footer_items")
 */
class Footer
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
    protected $text;
    /**
     * @ORM\Column(type="string")
     */
    protected $url;

    public function __construct($array) {
        setInfo($array);
    }

    public function toArray() {
        return [
            'text' => $this->text,
            'url' => $this->url
        ];
    }

    public function setTitle($string) {
        $this->title = $string;
    }

    public function setUrl($string) {
        $this->url = $string;
    }
}
