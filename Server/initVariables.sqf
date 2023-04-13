
/*
(findDisplay 46) displayAddEventHandler ["KeyDown", { 
 _key = _this # 1; 
 if (_key == 25) then { 
  [] spawn { 
   sleep 0.01; 
   { 
    if (ctrlIDD _x == 175) then { 
     _x closeDisplay 2; 
    }; 
   } forEach (uiNamespace getVariable "GUI_displays"); 
   _ds = (findDisplay 46) createDisplay "RscScoreboardMenu"; 
   _ds displayAddEventHandler ["KeyDown", { 
    [] spawn { 
     sleep 0.01; 
     { 
      if (ctrlIDD _x == 175) then { 
       _x closeDisplay 2; 
      }; 
     } forEach (uiNamespace getVariable "GUI_displays"); 
    }; 
   }]; 
  }; 
 }; 
}];
*/