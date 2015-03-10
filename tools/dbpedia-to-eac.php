<?php 

/************************
AUTHOR: Ethan Gruber
MODIFIED: September, 2012
DESCRIPTION: Generate network of EAC-CPF stubs strictly by crawling through dbpedia links
REQUIRED LIBRARIES: php5, php5-curl (if putting to eXist or other web service)
************************/

/************************
 * DEFINITION OF VARIABLES
 * $start = the starting point for the process
 * $end = the end point for the process, hypothetically.
 * $lang = the language of labels to extract from dbpedia.  if the $lang does not exist, the script will default to 'en'
 * $options = conditional options array for categories of data to import
 * $identityArray = ever-increasingly large array of dbpedia URIs and default labels
 * $processed = list of completed resources
 ************************/

/*****
* DEFINITION OF $options
* internal: CPF relations link internally (short URI for ID, lowercase version of dbpedia id,
* 		e.g., "antoninus_pius") or link externally to dbpedia resources, e.g., http://dbpedia.org/resource/Antoninus_Pius
* occupations: occupations uncommon in dbpedia; placed in cpfDescription/description
* subjects: placed in cpfDescription/description as <localDescription @localType='subject'>
* children/parents/dynasties/successors/predecessors/spouses/influences: cpfRelations
* resourceRelations: dbpedia-owl:wikiPageExternalLink in dbpedia RDF
* thumbnail: dbpedia-owl:thumbnail stored as a resourceRelation with @xlink:role='portrait'
*****/

$identityArray = array();
$processed = array();

$start = 'http://dbpedia.org/resource/Augustus';
$end = '';
$lang = 'en';
$options = array(
				'internal'=>true,
				'occupations'=>true,
				'subjects'=>false,
				'birth/death places'=>true,
				'children/parents'=>true,
				'dynasties'=>true,
				'successors/predecessors'=>true,
				'spouses'=>true,
				'influences'=>false,
				'resourceRelations'=>true,
				'thumbnail'=>true
			);



//generate EAC-CPF record
$xml = generate_eac($start, $end, $lang, $options);

//save file
$id =  strtolower(substr(strstr($start, 'resource/'), strpos(strstr($start, 'resource/'), '/') + 1));
$fileName = 'temp/' . $id . '.xml';
save_file($xml, $id, $fileName);

//process $identityArray
while (list($k, $v) = each($identityArray)){
	if (!in_array($k, $processed)){
		$id =  strtolower(substr(strstr($k, 'resource/'), strpos(strstr($k, 'resource/'), '/') + 1));
		$fileName = 'temp/' . $id . '.xml';
		$xml = generate_eac($k, $end, $lang, $options);
		
		save_file($xml, $id, $fileName);
	}
}

function generate_eac($resource, $end, $lang, $options){
	GLOBAL $identityArray;
	GLOBAL $processed;
	$processed[] =  $resource;
	
	$id =  substr(strstr($resource, 'resource/'), strpos(strstr($resource, 'resource/'), '/') + 1);
	
	//load dbpedia RDF
	$dbRDF = new DOMDocument();
	$dbRDF->load('http://dbpedia.org/data/' . $id . '.rdf');
	$dxpath = new DOMXpath($dbRDF);
	$dxpath->registerNamespace('rdf', "http://www.w3.org/1999/02/22-rdf-syntax-ns#");
	$dxpath->registerNamespace('dbpedia-owl', "http://dbpedia.org/ontology/");
	$dxpath->registerNamespace('rdfs', "http://www.w3.org/2000/01/rdf-schema#");
	$dxpath->registerNamespace('ns7', "http://live.dbpedia.org/ontology/");
	
	$xml = '<?xml version="1.0" encoding="utf-8"?><eac-cpf xmlns="urn:isbn:1-931666-33-4" xmlns:xlink="http://www.w3.org/1999/xlink">';
	
	/************ CONTROL ************/
	$xml .= '<control>';
	$xml .= '<recordId>' . strtolower($id) . '</recordId>';
	
	//get viaf RDF, if it exists
	$viafId = '';
	$viafIds = $dxpath->query('//dbpprop:viaf');
	foreach ($viafIds as $node){
		$viafId = $node->nodeValue;
	}
	if (strlen($viafId) > 0){
		$viafRDF = new DOMDocument();
		$viafRDF->load('http://viaf.org/viaf/' . $viafId . '/rdf.xml');
		$vxpath = new DOMXPath($viafRDF);
		$vxpath->registerNamespace('rdf', "http://www.w3.org/1999/02/22-rdf-syntax-ns#");
		$vxpath->registerNamespace('owl', "http://www.w3.org/2002/07/owl#");
		$vxpath->registerNamespace('schema', "http://schema.org/");
	}	
	
	$xml .= '<maintenanceAgency><agencyName>Agency Name</agencyName></maintenanceAgency>';
	$xml .= '<maintenanceHistory><maintenanceEvent><eventType>created</eventType><eventDateTime standardDateTime="' . date(DATE_W3C) . '"/><agentType>machine</agentType><agent>xEAC dbpedia PHP</agent></maintenanceEvent></maintenanceHistory>';
	$xml .= '<conventionDeclaration><abbreviation>WIKIPEDIA</abbreviation><citation>Wikipedia/DBpedia</citation></conventionDeclaration>';
	$xml .= '<sources><source xlink:type="simple" xlink:href="' . $resource . '"/>';
	if (strlen($viafId) > 0){
		$xml .= '<source xlink:type="simple" xlink:href="http://viaf.org/viaf/' . $viafId . '/"/>';
	}
	$xml .= '</sources>';
	$xml .= '</control><cpfDescription>';
	
	/************ IDENTITY ************/
	$xml .= '<identity>';
	
	//gather entityType
	$types = $dxpath->query('//rdf:type[rdf:resource="http://xmlns.com/foaf/0.1/Person"]');
	if (count($types) > 0){
		$xml .= '<entityType>person</entityType>';
	} else {
		$xml .= '<entityType>family</entityType>';
	}
	
	//other entityIDs
	$xml .= '<entityId>' . $resource . '</entityId>';
	
	//get other records from VIAF
	if (strlen($viafId) > 0){
		foreach ($vxpath->query("//rdf:Description[rdf:type/@rdf:resource='http://xmlns.com/foaf/0.1/Person']/schema:sameAs") as $ele){
			if (!strstr($ele->getAttribute('rdf:resource'), 'dbpedia')){
				$xml .= '<entityId>' . $ele->getAttribute('rdf:resource') . '</entityId>';
			}
		}
	}
	
	foreach ($dxpath->query('//rdfs:label') as $ele){
		$xml .= '<nameEntry xml:lang="' . $ele->getAttribute('xml:lang') . '"><part>' . $ele->nodeValue . '</part>';
		//set English as preferred label, otherwise alternative 
		if ($ele->getAttribute('xml:lang') == $lang){
			$xml .= '<preferredForm>WIKIPEDIA</preferredForm>';
		} else {
			$xml .= '<alternativeForm>WIKIPEDIA</alternativeForm>';
		}
		$xml .= '</nameEntry>';
	}
	$xml .= '</identity>';
	
	/************ DESCRIPTION ************/
	$xml .= '<description>';
	
	//get dbpedia abstract -> eac:biogHist
	$abstracts = $dxpath->query("//dbpedia-owl:abstract");
	$abstract = getLabel($abstracts, $lang);
	
	$xml .= '<biogHist><abstract xml:lang="' . $abstract['lang'] . '" localType="wikipedia">' . $abstract['label'] . '</abstract></biogHist>';
	
	//existDates, get from VIAF by default, if available
	if (strlen($viafId) > 0){
		$xml .= getExistDates($vxpath->query('//schema:birthDate')->item(0)->nodeValue, $vxpath->query('//schema:deathDate')->item(0)->nodeValue);
	} else {
		//else get from dbpedia (inconsistent)
		$startDates = $dxpath->query('//*[local-name()="birthDate"][@rdf:datatype="http://www.w3.org/2001/XMLSchema#date"]');
		$endDates = $dxpath->query('//*[local-name()="deathDate"][@rdf:datatype="http://www.w3.org/2001/XMLSchema#date"]');
		
		if (count($startDates) > 0 && count($endDates) > 0){
			if (strlen($startDates->item(0)->nodeValue) > 0 && strlen($endDates->item(0)->nodeValue) > 0){
				$gStart = $startDates->item(0)->nodeValue;
				$gEnd = $endDates->item(0)->nodeValue;
				$xml .= '<existDates><dateRange>';
				$xml .= '<fromDate standardDate="' . $gStart . '">' . getDateTextual($gStart) . '</fromDate>';
				$xml .= '<toDate standardDate="' . $gEnd . '">' . getDateTextual($gEnd) . '</toDate>';
				$xml .= '</dateRange></existDates>';
			}
		}	
	}
	
	//get birth and death places
	if ($options['birth/death places'] == true){
		$bdPlaces = $dxpath->query('descendant::dbpedia-owl:birthPlace|descendant::dbpedia-owl:deathPlace');
		foreach ($bdPlaces as $place){
			$localname = $place->localName;
			$url = $place->getAttribute('rdf:resource');
			//get label
			$tempId =  substr(strstr($url, 'resource/'), strpos(strstr($url, 'resource/'), '/') + 1);
			if (!array_key_exists($url, $identityArray)) {
				$labels = loadTempRDF($tempId);
				$label = 	getLabel($labels, $lang);
				$name = $label['label'];
			} else {
				$name = $identityArray[$url];
			}
			
			$xml .= '<place><placeEntry localVocabulary="' . $url . '">' . $name . '</placeEntry>';
			
			//set placeRole
			if ($localname == 'birthPlace'){
				$xml .= '<placeRole>Place of Birth</placeRole>';
			} else {
				$xml .= '<placeRole>Place of Death</placeRole>';
			}	
			
			//add date for birth or death, if available
			if (strlen($viafId) > 0){
				$query = ($localname == 'birthPlace') ? '//schema:birthDate' : '//schema:deathDate';
				$gDate = normalizeDate($vxpath->query($query)->item(0)->nodeValue);
				$xml .= '<date standardDate="' . $gDate . '">' . getDateTextual($gDate) . '</date>';
			} else {
				if (count($startDates) > 0 && count($endDates) > 0){
					if (strlen($startDates->item(0)->nodeValue) > 0 && strlen($endDates->item(0)->nodeValue) > 0){
						$gDate = ($localname == 'birthPlace') ? $startDates->item(0)->nodeValue : $endDates->item(0)->nodeValue;
						$xml .= '<date standardDate="' . $gDate . '">' . getDateTextual($gDate) . '</date>';
					}
				}
			}
			$xml .= '</place>';
		}
	}
	
	//get occupations
	if ($options['occupations'] == true){
		$occupations = $dxpath->query('descendant::rdf:Description[@rdf:about="' . $resource . '"]/dbpedia-owl:occupation');
		foreach ($occupations as $occupation){
			$url = $occupation->getAttribute('rdf:resource');
			$tempId =  substr(strstr($url, 'resource/'), strpos(strstr($url, 'resource/'), '/') + 1);
			if (!array_key_exists($url, $identityArray)) {
				$labels = loadTempRDF($tempId);
				$label = 	getLabel($labels, $lang);
				$name = $label['label'];
			} else {
				$name = $identityArray[$url];
			}
				
			$xml .= '<occupation>';
			$xml .= '<term vocabularySource="' . $url . '">' . $name . '</term>';
			$xml .= '</occupation>';
		}
	}
	//get subjects
	if ($options['subjects'] == true){
		$subjects = $dxpath->query('descendant::rdf:Description[@rdf:about="' . $resource . '"]/dcterms:subject');
		foreach ($subjects as $subject){
			$url = $subject->getAttribute('rdf:resource');
			$tempId =  substr(strstr($url, 'resource/'), strpos(strstr($url, 'resource/'), '/') + 1);
			if (!array_key_exists($url, $identityArray)) {
				$labels = loadTempRDF($tempId);
				$label = 	getLabel($labels, $lang);
				$name = $label['label'];
			} else {
				$name = $identityArray[$url];
			}
				
			$xml .= '<localDescription localType="subject">';
			$xml .= '<term vocabularySource="' . $url . '">' . $name . '</term>';
			$xml .= '</localDescription>';
		}
	}
	
	$xml .= '</description>';
	
	/************ RELATIONS ************/
	$xml .= getRelations($dxpath, $resource, $end, $lang, $options);
	
	//close EAC-CPF
	$xml .= '</cpfDescription></eac-cpf>';
	return $xml;
}

function loadTempRDF ($tempId){
	$tempRDF = new DOMDocument();
	$tempRDF->load('http://dbpedia.org/data/' . $tempId . '.rdf');
	$txpath = new DOMXpath($tempRDF);
	$txpath->registerNamespace('rdfs', "http://www.w3.org/2000/01/rdf-schema#");
	$labels = $txpath->query('//rdfs:label');
	
	return $labels;
}

function getLabel($elements, $lang){
	$array = array();
	
	foreach ($elements as $element){
		$array[$element->getAttribute('xml:lang')] = $element->nodeValue;
	}
	
	if (array_key_exists($lang, $array)) {
		return array('lang'=>$lang, 'label'=>$array[$lang]);
	} else {
		return array('lang'=>'en', 'label'=>$array['en']);
	}
}

function getRelations($dxpath, $resource, $end, $lang, $options){
	GLOBAL $identityArray;	
	
	$xml = '<relations>';	
	/*********** CPF RELATIONS *************/
	
	$nodeSets = array();
	
	//populate $nodeSets for xquery with $options
	if ($options['dynasties'] == true){
		$nodeSets[] = 'descendant::dbpprop:dynasty[@rdf:resource]';
		$nodeSets[] = 'descendant::dbpprop:house[@rdf:resource]';
		$nodeSets[] = 'descendant::dbpprop:royalHouse[@rdf:resource]';
	}
	if ($options['children/parents'] == true){
		//$nodeSets[] = 'descendant::dbpedia-owl:parent';
		$nodeSets[] = 'descendant::dbpprop:mother';
		$nodeSets[] = 'descendant::dbpprop:father';
	}
	if ($options['successors/predecessors'] == true){
		$nodeSets[] = 'descendant::dbpedia-owl:successor';
		$nodeSets[] = 'descendant::dbpedia-owl:predecessor';
	}
	if ($options['spouses'] == true){
		//get spouses from dbpprop:spouse and dbpedia-owl:spouse, but avoid duplication
		$nodeSets[] = 'descendant::*[local-name()="spouse"][not(@rdf:resource = preceding-sibling::*[local-name()="spouse"]/@rdf:resource)]';
	}
	if ($options['influences'] == true){
		$nodeSets[] = 'descendant::dbpedia-owl:influenced';
		$nodeSets[] = 'descendant::dbpedia-owl:influencedBy';
	}
	
	//attributes within the the resources main rdf:Description
	$mainAttr = array('house', 'dynasty', 'royalHouse','mother','father','parent','spouse','predecessor','successor','influenced');
	
	//execute xquery if $nodeSets has at least one item	
	if (count($nodeSets) > 0){
		$query = implode('|', $nodeSets);
		$relations = $dxpath->query($query);
			
		//populate array for cpfRelations
		$relationArray = array();
		foreach ($relations as $relation){
			$localname = $relation->localName;
			if ($relation->parentNode->getAttribute('rdf:about') == $resource && in_array($localname, $mainAttr)){
				switch ($localname){
					case 'house':
						$xlink = array('arcrole'=>'belongsToDynasty', 'role'=>'http://RDVocab.info/uri/schema/FRBRentitiesRDA/Family');
						break;
					case 'dynasty':
						$xlink = array('arcrole'=>'belongsToDynasty', 'role'=>'http://RDVocab.info/uri/schema/FRBRentitiesRDA/Family');
						break;
					case 'royalHouse':
						$xlink = array('arcrole'=>'belongsToDynasty', 'role'=>'http://RDVocab.info/uri/schema/FRBRentitiesRDA/Family');
						break;
					case 'parent':
						$xlink = array('arcrole'=>'childOf', 'role'=>'http://RDVocab.info/uri/schema/FRBRentitiesRDA/Person');
						break;
					case 'mother':
						$xlink = array('arcrole'=>'childOf', 'role'=>'http://RDVocab.info/uri/schema/FRBRentitiesRDA/Person');
						break;
					case 'father':
						$xlink = array('arcrole'=>'childOf', 'role'=>'http://RDVocab.info/uri/schema/FRBRentitiesRDA/Person');
						break;
					case 'spouse':
						$xlink = array('arcrole'=>'spouseOf', 'role'=>'http://RDVocab.info/uri/schema/FRBRentitiesRDA/Person');
						break;
					case 'successor':
						$xlink = array('arcrole'=>'predecessorOf', 'role'=>'http://RDVocab.info/uri/schema/FRBRentitiesRDA/Person');
						break;
					case 'predecessor':
						$xlink = array('arcrole'=>'successorOf', 'role'=>'http://RDVocab.info/uri/schema/FRBRentitiesRDA/Person');
						break;
					case 'influenced':
						$xlink = array('arcrole'=>'influenced', 'role'=>'http://RDVocab.info/uri/schema/FRBRentitiesRDA/Person');
						break;
					case 'influencedBy':
						$xlink = array('arcrole'=>'influencedBy', 'role'=>'http://RDVocab.info/uri/schema/FRBRentitiesRDA/Person');
						break;
					default:
						$xlink = array('arcrole'=>'NULL1', 'role'=>'http://RDVocab.info/uri/schema/FRBRentitiesRDA/Person');
						break;
				}
				
				$url = $relation->getAttribute('rdf:resource');
				
				if ($xlink['arcrole'] != 'NULL1'){
					//get label
					$tempId =  substr(strstr($url, 'resource/'), strpos(strstr($url, 'resource/'), '/') + 1);
					if (strlen($url) > 0){
						if (!array_key_exists($url, $identityArray)) {
							$labels = loadTempRDF($tempId);
							$label = getLabel($labels, $lang);
							$name = $label['label'];
								
							//don't add the $end dbpedia resource into $identityArray
							if ($resource != $end){
								$identityArray[$url] = $name;
							}
						} else {
							$name = $identityArray[$url];
						}
					} else {
						$name = $relation->nodeValue;
					}
					
					//get href, whether internal or external
					if ($options['internal'] == true){
						$href = strtolower($tempId);
					} else {
						$href = $url;
					}
					
					$relationArray[] = array('href'=>$href, 'label'=>$name, 'arcrole'=>$xlink['arcrole'], 'role'=>$xlink['role']);					
				}
				
				
			} elseif ($relation->parentNode->getAttribute('rdf:about') != $resource) {
				switch ($localname){
					case 'parent':
						$xlink = array('arcrole'=>'parentOf', 'role'=>'http://RDVocab.info/uri/schema/FRBRentitiesRDA/Person');
						break;
					case 'house':
						$xlink = array('arcrole'=>'dynastyOf', 'role'=>'http://RDVocab.info/uri/schema/FRBRentitiesRDA/Person');
						break;
					case 'dynasty':
						$xlink = array('arcrole'=>'dynastyOf', 'role'=>'http://RDVocab.info/uri/schema/FRBRentitiesRDA/Person');
						break;
					case 'royalHouse':
						$xlink = array('arcrole'=>'dynastyOf', 'role'=>'http://RDVocab.info/uri/schema/FRBRentitiesRDA/Person');
						break;
					case 'influenced':
						$xlink = array('arcrole'=>'influencedBy', 'role'=>'http://RDVocab.info/uri/schema/FRBRentitiesRDA/Person');
						break;
					default:
						$xlink = array('arcrole'=>'NULL2', 'role'=>'http://RDVocab.info/uri/schema/FRBRentitiesRDA/Person');
						break;
				}
				$url = $relation->parentNode->getAttribute('rdf:about');
				
				//get label
				if ($xlink['arcrole'] != 'NULL2'){
					$tempId =  substr(strstr($url, 'resource/'), strpos(strstr($url, 'resource/'), '/') + 1);
					if (strlen($url) > 0){
						if (!array_key_exists($url, $identityArray)) {
							$labels = loadTempRDF($tempId);
							$label = getLabel($labels, $lang);
							$name = $label['label'];
								
							//don't add the $end dbpedia resource into $identityArray
							if ($resource != $end){
								$identityArray[$url] = $name;
							}
						} else {
							$name = $identityArray[$url];
						}
					} else {
						$name = $relation->nodeValue;
					}
					
					//get href, whether internal or external
					if ($options['internal'] == true){
						$href = strtolower($tempId);
					} else {
						$href = $url;
					}
				
					$relationArray[] = array('href'=>$href, 'label'=>$name, 'arcrole'=>$xlink['arcrole'], 'role'=>$xlink['role']);
				}
			}
		}
	}

	/*** GENERATE CPFRELATION ELEMENTS ***/
	foreach ($relationArray as $rel){
		$xml .= '<cpfRelation xlink:type="simple"' . (strlen($rel['href']) > 0 ? ' xlink:href="' . $rel['href'] . '"' : '') . ' xlink:role="' . $rel['role'] . '" xlink:arcrole="' . $rel['arcrole'] . '">';
		$xml .= '<relationEntry>' . $rel['label'] . '</relationEntry>';
		$xml .= '</cpfRelation>';
	}
	
	/*********** END CPF RELATIONS *************/
	
	//get thumbnail resource relation
	if ($options['thumbnail'] == true){
		$thumbnails = $dxpath->query("//*[local-name()='thumbnail']");
		foreach ($thumbnails as $thumbnail){
			if ($thumbnail->hasAttribute('rdf:resource') === TRUE){
				$xml .= '<resourceRelation xlink:type="simple" xlink:href="' . $thumbnail->getAttribute('rdf:resource') . '" xlink:role="portrait">';
				$xml .= '<relationEntry>Thumbnail</relationEntry>';
				$xml .= '</resourceRelation>';
			}
		}
	}
	
	//get resource relatons from dbpedia
	if ($options['resourceRelations'] == true){
		$resources = $dxpath->query('descendant::dbpedia-owl:wikiPageExternalLink');
		foreach($resources as $resource){
			$xml .= '<resourceRelation xlink:type="simple" xlink:href="' . str_replace('&', '&amp;', $resource->getAttribute('rdf:resource')) . '" xlink:role="subjectOf">';
			$xml .= '<relationEntry>' . str_replace('&', '&amp;', $resource->getAttribute('rdf:resource')) . '</relationEntry>';
			$xml .= '</resourceRelation>';
		}
	}
	
	$xml .= '</relations>';
	//return $xml
	return $xml;
}

function getExistDates($startDate, $endDate){
		$gDateStart = normalizeDate($startDate);
		$gDateEnd = normalizeDate($endDate);
		
		$xml = '<existDates><dateRange>';
		$xml .= '<fromDate standardDate="' . $gDateStart . '">' . getDateTextual($gDateStart) . '</fromDate>';
		$xml .= '<toDate standardDate="' . $gDateEnd . '">' . getDateTextual($gDateEnd) . '</toDate>';
		$xml .= '</dateRange></existDates>';
		
		return $xml;
}

function normalizeDate($date){
	$gDate = '';
	if (strpos($date, '-') !== FALSE){
		$segs = explode('-', $date);
		if (strpos($date, '-') == 0){
			//if BC
			$gDate .= '-';
			foreach ($segs as $k=>$v){
				if ($k == 1){
					$gDate .= str_pad((int) $v,4,"0",STR_PAD_LEFT);
				} elseif ($k > 1) {
					$gDate .= '-' . $v;
				}
			}
		} else {
			//if AD
			foreach ($segs as $k=>$v){
				if ($k == 0){
					$gDate .= str_pad((int) $v,4,"0",STR_PAD_LEFT);
				} else {
					$gDate .= '-' . $v;
				}
			}
		}
	} else {
		$gDate .= str_pad((int) $date,4,"0",STR_PAD_LEFT);
	}
	return $gDate;
}

function getDateTextual ($date){
	$textDate = '';
	if (strpos($date, '-') !== FALSE){
		$segs = explode('-', $date);
		if (strpos($date, '-') == 0){
			//if BC
			//day
			if (strlen($segs[3]) > 0){
				$textDate .= $segs[3] . ' ';
			}
			//month
			if (strlen($segs[2]) > 0){
				$textDate .= normalizeMonth($segs[2]) . ' ';
			}			
			//year
			$textDate .= (int) $segs[1] . ' B.C.';
		} else {
			//if AD
			//day
			if (strlen($segs[2]) > 0){
				$textDate .= $segs[2] . ' ';
			}
			//month
			if (strlen($segs[1]) > 0){
				$textDate .= normalizeMonth($segs[1]) . ' ';
			}			
			//year
			$textDate .= ((int) $segs[0] < 400 ? 'A.D. ' : '') . (int) $segs[0];
		}
	} else {
		$textDate = ((int) $date < 400 ? 'A.D. ' : '') . (int) $date;
	}
	return $textDate;
}

function normalizeMonth($month){
	$monthName = '';
	switch ((int) $month){
		case 1:
			$monthName = 'January';
			break;
		case 2:
			$monthName = 'February';
			break;
		case 3:
			$monthName = 'March';
			break;
		case 4:
			$monthName = 'April';
			break;
		case 5:
			$monthName = 'May';
			break;
		case 6:
			$monthName = 'June';
			break;
		case 7:
			$monthName = 'July';
			break;
		case 8:
			$monthName = 'August';
			break;
		case 9:
			$monthName = 'September';
			break;
		case 10:
			$monthName = 'October';
			break;
		case 11:
			$monthName = 'November';
			break;
		case 12:
			$monthName = 'December';
			break;
	}
	return $monthName;
}

function save_file($xml, $id, $fileName){
	$dom = new DOMDocument;
	$dom->preserveWhiteSpace = FALSE;
	$dom->loadXML($xml);
	if ($dom->loadXML($xml) === FALSE){
		echo "Failed to validate in DOMDocument: {$id}.\n";
	} else {
		$dom->formatOutput = TRUE;		
		echo "Wrote {$id}.\n";
		//echo $dom->saveXML();
		//comment out the line below and uncomment the block below to enable saving to eXist
		$dom->save($fileName);
			
		//save to eXist
		/*if (($readFile = fopen($fileName, 'r')) === FALSE){
			echo "Failed to read file: {$id}.\n";
		} else {
			echo "Wrote {$id}.\n";
			//PUT xml to eXist
			$putToExist=curl_init();
			
			//set curl opts
			curl_setopt($putToExist,CURLOPT_URL,'http://localhost:8080/exist/rest/db/xeac/records/' . $id . '.xml');
			curl_setopt($putToExist,CURLOPT_HTTPHEADER, array("Content-Type: text/xml; charset=utf-8"));
			curl_setopt($putToExist,CURLOPT_CONNECTTIMEOUT,2);
			curl_setopt($putToExist,CURLOPT_RETURNTRANSFER,1);
			curl_setopt($putToExist,CURLOPT_PUT,1);
			curl_setopt($putToExist,CURLOPT_INFILESIZE,filesize($fileName));
			curl_setopt($putToExist,CURLOPT_INFILE,$readFile);
			curl_setopt($putToExist,CURLOPT_USERPWD,"admin:");
			$response = curl_exec($putToExist);
				
			$http_code = curl_getinfo($putToExist,CURLINFO_HTTP_CODE);
				
			//close eXist curl
			curl_close($putToExist);
		}*/
	}
}
?>