from files/userData import userMail, userMailWord , targetMailTest, targetMailNameTest, smtpServer, smtpServerPort
import asyncdispatch, logging, smtp, strformat, strutils, mime

type Mailer* = object
  ## Mailer which holds necessary information for sending emails
  ## type objects need to hold usernames and passwords
  ## which might be a security risk!
  address: string
  port: Port
  myAddress: string
  myName: string
  username: string
  password: string
  
proc newMailer*(address, port, myAddress, myName, username, password: string): Mailer =
  ## Constructer for Mailer type
  result = Mailer(
    address: address,
    port: port.parseInt.Port,
    myAddress: myAddress,
    myName: myName,
    username: username,
    password: password,
  )

proc sendNewMail*(m: Mailer, to, toName, subject, body: string) {.async.} =
  ## central function for the sending of emails through the Mailer type
  ## Takes string inputs:
  ## to: email address of target
  ## toName: name of target
  ## subject: subject line of mail
  ## body: message text
  let
      toList = @[fmt"{to}"]
      msg = createMessage(subject, body, toList, @[], [
      ("From", fmt"{m.myAddress}"),
      ("MIME-Version", "1.0"),
      ("Content-Type", "text/plain"),
      ])

  var client = newAsyncSmtp(useSsl = true, debug=true)
  await client.connect(m.address, m.port)
  await client.auth(m.username, m.password)
  echo ""
  echo ""
  echo $msg
  echo ""
  echo ""
  await client.sendMail(fmt"{m.myAddress}", toList, $msg)
  info "sent email to: ", to, " about: ", subject
  await client.close()

proc sendNewFile* (m: Mailer, to, toName, subject, body: string, file : string) {.async.} =
  ## central function for the sending of emails with attached files through the Mailer type
  ## Takes string inputs:
  ## to: email address of target
  ## toName: name of target
  ## subject: subject line of mail
  ## body: message text
  ## file: location of file to be send
  var attachement = newAttachment(readFile(file), filename = file)
  let
      toList = @[fmt"{to}"]
      msg = createMessage(subject, body, toList, @[], [
      ("From", fmt"{m.myAddress}"),
      ("MIME-Version", "1.0"),
      ("Content-Type", "text/plain"),
      ])
  var email = newEmail(subject, body, m.myAddress, @[to], attachments = @[attachement])

  var client = newAsyncSmtp(useSsl = true, debug=true)
  await client.connect(m.address, m.port)
  await client.auth(m.username, m.password)
  echo ""
  echo ""
  echo $msg
  echo ""
  echo ""
  await client.sendMail(fmt"{m.myAddress}", toList, $email.finalize())
  info "sent email to: ", to, " about: ", subject
  await client.close()

var mailBot* : Mailer

try:  
  mailBot = newMailer(smtpServer, smtpServerPort, userMail, targetMailNameTest, userMail, userMailWord)
except ValueError:
  echo "Initalization of mail functionalities failed. Did you insert your data into ./files/userData.nim?"