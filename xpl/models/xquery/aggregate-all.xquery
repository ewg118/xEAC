declare namespace eac="urn:isbn:1-931666-33-4";
declare namespace xlink="http://www.w3.org/1999/xlink";
<group>
   {
         for $doc in collection('/db/xeac/records/')[descendant::eac:publicationStatus='approved']
         return $doc 
      }
</group>