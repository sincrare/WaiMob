if User.count == 0
  User.create(email: "waimob@test.com", password: "aaaaaa", password_confirmation: "aaaaaa")
end

if Document.count == 0
  document = Document.create(title: "first document")
  document.rows.create(content: '1行目')
  document.rows.create(content: '2行目')
end
