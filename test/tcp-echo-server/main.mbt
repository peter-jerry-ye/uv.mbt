///|
fn main {
  try {
    let default_port = 7001
    let default_backlog = 128
    let uv = @uv.Loop::new!()
    let server = @uv.Tcp::new!(uv)
    let addr = @uv.ip4_addr("0.0.0.0", default_port)
    server.bind!(addr, 0)
    fn alloc_buffer(_ : @uv.Tcp, suggested_size : Int) {
      Bytes::make(suggested_size, 0)[:]
    }

    fn on_close(_) {

    }

    fn echo_write(_ : @uv.Write) {

    }

    fn echo_read(client : @uv.Tcp, nread : Int, buf : @bytes.View) {
      try {
        client.write!([buf[:nread]], echo_write, fn(_, error) {
          println("Write error: \{error}")
        })
      } catch {
        error => println("Write error: \{error}")
      }
    }

    fn on_new_connection(server) {
      try {
        let client = @uv.Tcp::new!(uv)
        if @uv.accept(server, client.to_stream()) == 0 {
          client.read_start!(alloc_buffer, echo_read, fn(_, error) {
            if not(error is EOF) {
              println("Read error: \{error}")
            }
            @uv.close(client.to_handle(), on_close)
          })
        } else {
          @uv.close(client.to_handle(), on_close)
        }
      } catch {
        error => println("Accept error: \{error}")
      }
    }

    server.listen!(default_backlog, on_new_connection, fn(_, error) {
      println("Listen error: \{error}")
    })
    uv.run!(Default) |> ignore()
  } catch {
    error => println("Error: \{error}")
  }
}
