worker_processes 4
@app_path = '../lib/new_stephen'

listen "#{@app_path}/var/run/unicorn.sock", :backlog => 64
pid "#{@app_path}/var/run/unicorn.pid"
