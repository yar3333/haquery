package php;

extern interface Serializable
{
  public function serialize() : String;
  public function unserialize(serialized:String) : Void;
}
