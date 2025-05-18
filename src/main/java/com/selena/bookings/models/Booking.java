package com.selena.bookings.models;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
public class Booking {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long userId;
    private Long hotelId;
    private LocalDate checkInDate;
    private LocalDate checkOutDate;

    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
}