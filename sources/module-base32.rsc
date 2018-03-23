:global decodeBase32;
:global decodeBase32 do={
    :global CHARTOBYTE;
    
    :local str $1;
    :local strLength [:len $str];
    :local numBytes ((($strLength * 5) + 7) / 8);
    :local result ({});
    :local resultIndex 0;
    :local which 0;
    :local working 0;
    
    :local index 0;
    :local break false;
    :while (($index < $strLength) && (!$break)) do={
        :local val ($CHARTOBYTE->[:pick $str $index]);
        #:put "index: $index";
        #:put "val: $val";
        :if ($val >= 97 && $val <= 122) do={
            :set val ($val - 97);
        } else={
            :if ($val >= 65 && $val <= 90) do={
                :set val ($val - 65);
            } else={
                :if ($val >= 50 && $val <= 55) do={
                    :set val (26 + ($val - 50));
                } else={
                    :if ($val = 61) do={
                        #special case
                        :set which 0;
                        :set break true;
                        #:put "break $break";
                    } else={
                        #Error
                    }                
                }
            }
        }
        
        :if (!$break) do={
            :if ($which = 0) do={
                :set working (($val & 0x1F) << 3);
                :set which 1;        
            } else={
                :if ($which = 1) do={
                    :set working ($working | (($val & 0x1C) >> 2));
                    :set ($result->$resultIndex) $working;
                    :set resultIndex ($resultIndex + 1);
                    :set working (($val & 0x03) << 6);
                    :set which 2;            
                } else={
                    :if ($which = 2) do={
                        :set working ($working | (($val & 0x1F) << 1));
                        :set which 3;                
                    } else={
                        :if ($which = 3) do={
                            :set working ($working | (($val & 0x10) >> 4));
                            :set ($result->$resultIndex) $working;
                            :set resultIndex ($resultIndex + 1);
                            :set working (($val & 0x0F) << 4);
                            :set which 4;                    
                        } else={
                            :if ($which = 4) do={
                                :set working ($working | (($val & 0x1E) >> 1));
                                :set ($result->$resultIndex) $working;
                                :set resultIndex ($resultIndex + 1);
                                :set working (($val & 0x01) << 7);
                                :set which 5;
                            } else={
                                :if ($which = 5) do={
                                    :set working ($working | (($val & 0x1F) << 2));
                                    :set which 6;
                                } else={
                                    :if ($which = 6) do={
                                        :set working ($working | (($val & 0x18) >> 3));
                                        :set ($result->$resultIndex) $working;
                                        :set resultIndex ($resultIndex + 1);
                                        :set working (($val & 0x07) << 5);
                                        :set which 7;                                
                                    } else={
                                        :if ($which = 7) do={
                                            :set working ($working | ($val & 0x1F));
                                            :set ($result->$resultIndex) $working;
                                            :set resultIndex ($resultIndex + 1);
                                            :set which 0;
                                        }                                
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        :set index ($index + 1);
    }    

    :if ($which != 0) do={
        :set ($result->$resultIndex) $working;
    }
    
    #:put "result";
    #:put $result;
    :return $result;
}

#$decodeBase32 "GEZDGNBVGY======";

#2 50
#7 55
#A 65
#Z 90
#a 97
#z 122
#= 61