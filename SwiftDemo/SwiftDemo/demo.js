defineClass('SwiftDemo.ViewController', {
	viewDidLoad: function() {
		console.log('js viewDidLoad begin')
		self.ORIGviewDidLoad()
		console.log('js viewDidLoad end')
	},
	
	testLog: function() {
		console.log('js ViewController testlog')
	},
	
	tableView_numberOfRowsInSection: function(tableView, section) {
		return 10
	}
})

defineClass('SwiftDemo.TestObject', {
	testLog: function() {
		console.log('js TestObject testlog')
	}
})