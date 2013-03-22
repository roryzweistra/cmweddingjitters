package WebGUI::Content::Gifts;

$VERSION = "1.0.0";

#-------------------------------------------------------------------
# Copyright Ryuu 2013
#-------------------------------------------------------------------
# http://www.ryuu.nl                                  rory@ryuu.nl
#-------------------------------------------------------------------

use strict;
use Data::Dumper;

#---------------------------------------------------------------------

sub handler {
    my $session	= shift;
    my $url		= $session->url->getRequestedUrl;
    
    return unless ( $session->form->param('authorise_gift') eq 'authorise' );
    $session->log->error("na url url: " . $url);	
    $session->log->error("params: " . Dumper($session->form->paramsHashRef));	
    my $output;

    my $name	= $session->form->process( 'name' );
    my $email	= $session->form->process( 'email' );
    my $gift	= $session->form->process( 'gift' );

    my $sql = 'UPDATE giftslist SET name = ?, email = ?, gift = ? WHERE id = ?';
    $session->db->write( $sql, [ $name, $email, 1, $gift ]);


    my $mail    = WebGUI::Mail::Send->create( $session, {
    	to          => 'lottizwemmer@gmail.com',
        bcc	    => 'rory@ryuu.nl',
        subject     => 'CM Gift request'
    });

    my $gift_description = $session->db->quickScalar( 'SELECT description FROM giftslist WHERE id = ?', [$gift] );

    my $body = "Name : $name<br /> Email : $email<br /> Gift : $gift_description";

    $mail->addHtml( $body );

    $mail->send;

    my $guest_mail = WebGUI::Mail::Send->create( $session, {
	to => $email,
        bcc => 'rory@ryuu.nl',
        subject => 'Thanks for your gift!'
    });

    my $guest_mail_body = "Thank you so much for your gift. You will receive an email with instructions shortly.";

    $guest_mail->addHtml( $guest_mail_body );

    $guest_mail->send;

    return $output;
}

1;
