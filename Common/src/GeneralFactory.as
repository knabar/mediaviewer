package
{
	
	import flash.system.ApplicationDomain;
	import flash.system.Security;
	
	import mdm.Application;
	
	public class GeneralFactory
	{
		public static const NOT_SUPPORTED_IN_WEB_MESSAGE:String = "Not supported in web version.";
		public static const MDID2:String = "mdid2Mode";
		public static const MDID3:String = "mdid3Mode";
		public static const AIR_MODE:String = "AIR mode.";
		public static const WEB_MODE:String = "Web mode.";
		public static const ZINC_MODE:String = "Zinc mode.";
		
		private static var general:IGeneral = null;
			
		static public function getInstance():IGeneral
		{
			if (general != null) return general;
			var cls:String = (isAir ? "AirGeneralImplementation" : (isZinc ? "ZincGeneralImplementation" : "WebGeneralImplementation"));
			var clsToCreate:Object = getClassToCreate(cls);
			general = new clsToCreate();
			return  general;
		}
		
		static private function getClassToCreate(className:String):Object {			
			var someClass:Object = null;
			try {
				someClass = ApplicationDomain.currentDomain.getDefinition(className);
				//trace(className);
			} catch(e:Error) { 
				//we are compiling ZincMediaViewer...next line needed to force Zinc compilation.
				someClass = ApplicationDomain.currentDomain.getDefinition("ZincGeneralImplementation");
			}
			return someClass;
		}
		
		static public function get isAir():Boolean {			
			//	Since "application" is only defined in the AIR framework, trying
			//	to match for Security.APPLICATION will fail.  This is why I'm
			//	using the string, instead of the statically compiled constant.
			return Security.sandboxType.toString() == "application" ? true : false;
		}
		static public function get isZinc():Boolean {
			try {
				var myResult:String = mdm.Application.getGlobalVar("isRunningInZinc");
				if (myResult != null && myResult.toLowerCase() == "true") {
					return true;
				}
			} catch (e:Error) {
				return false;
			}
			return false;
		}
	}
}