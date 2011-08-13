<?php
require_once dirname(__FILE__).'/../../../HaqXml.extern.php';

class haquery_components_listitem_Server extends haquery_server_HaqComponent {
	public function __construct() { if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haquery.components.listitem.Server::new");
		$»spos = $GLOBALS['%s']->length;
		parent::__construct();
		$GLOBALS['%s']->pop();
	}}
	public function construct($manager, $parent, $tag, $id, $doc, $params, $innerHTML) {
		$GLOBALS['%s']->push("haquery.components.listitem.Server::construct");
		$»spos = $GLOBALS['%s']->length;
		$doc = new HaqXml($innerHTML);
		if($params !== null && $params->exists("seralizedParams")) {
			$childrenParams = php_Lib::unserialize($params->get("seralizedParams"));
			if(null == $childrenParams) throw new HException('null iterable');
			$»it = $childrenParams->keys();
			while($»it->hasNext()) {
				$id1 = $»it->next();
				$elems = new _hx_array($doc->find("#" . $id1));
				{
					$_g = 0;
					while($_g < $elems->length) {
						$e = $elems[$_g];
						++$_g;
						$childrenAttrs = $childrenParams->get($id1);
						if(null == $childrenAttrs) throw new HException('null iterable');
						$»it2 = $childrenAttrs->keys();
						while($»it2->hasNext()) {
							$attrName = $»it2->next();
							$e->setAttribute($attrName, $childrenAttrs->get($attrName));
						}
						unset($e,$childrenAttrs);
					}
					unset($_g);
				}
				unset($elems);
			}
		}
		parent::construct($manager,$parent,$tag,$id,$doc,$params,"");
		$GLOBALS['%s']->pop();
	}
	public function connectEventHandlers($child, $event) {
		$GLOBALS['%s']->push("haquery.components.listitem.Server::connectEventHandlers");
		$»spos = $GLOBALS['%s']->length;
		$handlerName = $this->parent->id . "_" . $child->id . "_" . $event->name;
		if(Reflect::hasMethod($this->parent->parent, $handlerName)) {
			$event->bind($this->parent->parent, Reflect::field($this->parent->parent, $handlerName));
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haquery.components.listitem.Server'; }
}
