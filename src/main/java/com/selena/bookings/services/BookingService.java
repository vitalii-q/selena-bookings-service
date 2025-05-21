package com.selena.bookings.services;

import com.selena.bookings.dto.UpdateBookingRequest;
import com.selena.bookings.models.Booking;
import com.selena.bookings.repositories.BookingRepository;

import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class BookingService {

    private final BookingRepository bookingRepository;

    public BookingService(BookingRepository bookingRepository) {
        this.bookingRepository = bookingRepository;
    }

    public List<Booking> findAll() {
        return bookingRepository.findAll();
    }

    public Optional<Booking> findById(Long id) {
        return bookingRepository.findById(id);
    }

    public Booking save(Booking booking) {
        return bookingRepository.save(booking);
    }

    public void deleteById(Long id) {
        bookingRepository.deleteById(id);
    }

    public Booking partialUpdate(Long id, UpdateBookingRequest request) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Booking not found"));

        if (request.getUserId() != null) {
            booking.setUserId(request.getUserId());
        }
        if (request.getHotelId() != null) {
            booking.setHotelId(request.getHotelId());
        }
        if (request.getRoomId() != null) {
            booking.setRoomId(request.getRoomId());
        }
        if (request.getCheckInDate() != null) {
            booking.setCheckInDate(request.getCheckInDate());
        }
        if (request.getCheckOutDate() != null) {
            booking.setCheckOutDate(request.getCheckOutDate());
        }
        if (request.getStatus() != null) {
            booking.setStatus(request.getStatus());
        }

        return bookingRepository.save(booking);
    }
}