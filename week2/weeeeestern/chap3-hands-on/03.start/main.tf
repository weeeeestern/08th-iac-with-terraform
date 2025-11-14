resource "local_file" "abc" { #로컬 프로바이더
  content  = "123!"
  filename = "${path.module}/abc.txt"
}

resource "local_file" "def" { #로컬 프로바이더
depends_on = [
    local_file.abc    #local_file.abc 에 대한 종속성 명시
]
  content  = "456!"
  filename = "${path.module}/def.txt"
}