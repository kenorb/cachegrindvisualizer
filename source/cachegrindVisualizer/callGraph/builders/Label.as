package cachegrindVisualizer.callGraph.builders
{
	import develar.formatters.NumberFormatter;
	
	import mx.formatters.NumberBaseRoundType;
	
	public class Label
	{
		public static const TYPE_PERCENTAGE:uint = 0;
		public static const TYPE_TIME:uint = 1;
		public static const TYPE_PERCENTAGE_AND_TIME:uint = 2;
		public static const TYPE_TIME_AND_PERCENTAGE:uint = 3;
		
		public static const TYPE_NO:uint = 4;
		
		private static const INCLUDE_FUNCTIONS:Object = {'include': null, 'include_once': null, 'require': null, 'require_once': null};
		private static const MAX_INCLUDE_FILE_PATH_LENGTH:uint = 20;
			
		private static const TIME_PRECISION:int = -1;
		private static const PERCENTAGE_PRECISION:uint = 2;
		
		private static var percentageFormatter:NumberFormatter = new NumberFormatter();
		private static var timeFormatter:NumberFormatter = new NumberFormatter();
		
		private var names:Object;
		
		public function Label(names:Object):void
		{
			this.names = names;
			
			timeFormatter.precision = TIME_PRECISION;
			
			percentageFormatter.precision = PERCENTAGE_PRECISION;
			percentageFormatter.rounding = NumberBaseRoundType.NEAREST;
		}
		
		private var _type:uint = TYPE_PERCENTAGE_AND_TIME;
		public function set type(value:uint):void
		{
			_type = value;
		}
		
		public function edge(edge:Edge):String
		{		
			var result:String = '';
			if (_type != Label.TYPE_NO)
			{
				result += ' label="' + build(edge.inclusivePercentage, edge.inclusiveTime) + '"';
				// если узел не имеет детей (то есть собственное время равно включенному), то смысла в метке острия ребра нет - она всегда будет равна метке ребра
				if (edge.time > 0 && edge.time != edge.inclusiveTime)
				{
					result += ' headlabel="' + build(edge.percentage, edge.time) + '"';
				}
			}	
			return result;
		}
		
		public function node(node:Node):String
		{
			var name:String = names[node.name];
			
			var label:String = 'label="';			
			var parts:Array = name.split('::', 2);;
			if (parts.length == 2 && parts[0] in INCLUDE_FUNCTIONS)
			{
				if (parts[1].length > MAX_INCLUDE_FILE_PATH_LENGTH)
				{
					var path:String = parts[1];					
					var fileName:String = '';
					var char:String;
					for (var i:uint = path.length - 1; i > 1; i--)
					{
						char = path.charAt(i);
						if (char == '/' || char == '\\')
						{
							break;
						}
						else
						{
							fileName = char + fileName;
						}
					}
					path = path.substr(0, i);
					var length:Number = (path.length / 2) - ((path.length - MAX_INCLUDE_FILE_PATH_LENGTH) / 2);
					path = path.substr(0, length) + '…' + path.substr(-length);
					label += parts[0] + '::' + (path + char).replace(/\\/g, '\\\\') + fileName;
				}
				else
				{
					label += name.replace(/\\/g, '\\\\');
				}				
			}
			else
			{
				label += name;
			}	
			
			if (_type != TYPE_NO)
			{
				label += '\\n' + build(node.inclusivePercentage, node.inclusiveTime);
			}
			return label + '"';
		}
		
		protected function build(percentage:Number, time:uint):String
		{			
			switch (_type)
			{
				case TYPE_PERCENTAGE_AND_TIME:
				{
					return percentageFormatter.format(percentage) + ' % (' + timeFormatter.format(time) + ')';
				}
				break;
				
				case TYPE_TIME_AND_PERCENTAGE:
				{
					return timeFormatter.format(time) + ' (' + percentageFormatter.format(percentage) + ' %)';
				}
				break;
				
				case TYPE_PERCENTAGE:
				{
					return percentageFormatter.format(percentage) + ' %';
				}
				break;
					
				case TYPE_TIME:
				{
					return timeFormatter.format(time);
				}
				break;
					
				default:
				{
					throw new Error('Unknown label type');
				}	
				break;				
			}
		}
	}
}