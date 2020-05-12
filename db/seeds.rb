if User.count == 0
  User.create(email: "waimob@test.com", password: "aaaaaa", password_confirmation: "aaaaaa")
end

if Document.count == 0
  document = Document.create(title: "first document")
  r1 = document.rows.create(content: '1行目')
  r2 = document.rows.create(content: '2行目')

  r1.next_row = r2
  r1.save!

  r2.previous_row = r1
  r2.save!
end
